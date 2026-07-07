//
//  TemplatePDFService.swift
//  Harvie
//

import AppKit
import Foundation
import ObjectiveC
import PDFKit
import WebKit
import os.log

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "app.harvie", category: "TemplatePDF")

@MainActor
final class TemplatePDFService {
    static let shared = TemplatePDFService()

    // A4 dimensions in points (72 dpi): 595.28 x 841.89
    static let a4Width: CGFloat = 595.28
    static let a4Height: CGFloat = 841.89

    /// Hidden window that provides the window-server context WKWebView needs.
    /// Positioned on-screen with near-zero alpha so the window server allocates GPU resources.
    private lazy var renderWindow: NSWindow = {
        let window = NSWindow(
            contentRect: CGRect(x: 0, y: 0, width: Self.a4Width, height: Self.a4Height),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.alphaValue = 0.01
        window.collectionBehavior = [.ignoresCycle, .stationary]
        window.orderBack(nil)
        return window
    }()

    func renderPDF(html: String, css: String, baseURL: URL? = nil) async throws -> PDFDocument {
        let fullHTML = buildHTMLDocument(html: html, css: css)
        return try await renderHTMLToPDF(fullHTML, baseURL: baseURL)
    }

    func renderWatermarkPage(text: String, dateText: String?, css: String) async throws -> PDFPage {
        var dateDiv = ""
        if let dateText {
            dateDiv = "<div class=\"date\">\(dateText)</div>"
        }

        let html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="UTF-8">
        <style>
        @page { size: A4; margin: 0; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html { zoom: 0.75; }
        html, body { width: 210mm; height: 297mm; position: relative; overflow: hidden; }
        \(css)
        </style>
        </head>
        <body>
        <div class="watermark">
            <div class="text">\(text)</div>
            \(dateDiv)
        </div>
        </body>
        </html>
        """

        let a4Rect = CGRect(origin: .zero, size: CGSize(width: Self.a4Width, height: Self.a4Height))
        let document = try await renderHTMLToPDF(html, rect: a4Rect)
        guard let page = document.page(at: 0) else {
            throw PDFNavigationDelegate.PDFError.renderingFailed
        }
        return page
    }

    func renderTemplate(
        template: InvoiceTemplate,
        context: [String: Any],
        columnVisibility: ColumnVisibility = .default
    ) async throws -> PDFDocument {
        let processedHTML = TemplateEngine.render(template.resolvedHTMLContent(), with: context)
        let css = template.resolvedCSSContent() + "\n" + columnVisibility.cssVariables()
        let baseURL = template.isBuiltIn ? nil : TemplateFileManager.existingDirectory(for: template.id)
        return try await renderPDF(html: processedHTML, css: css, baseURL: baseURL)
    }

    private func buildHTMLDocument(html: String, css: String) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
        @page {
            size: A4;
            margin: 0;
        }
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        html {
            zoom: 0.75;
        }
        html, body {
            width: 210mm;
            min-height: 297mm;
            font-family: -apple-system, BlinkMacSystemFont, 'Helvetica Neue', sans-serif;
        }
        @media print {
            html {
                zoom: 0.75;
            }
            html, body {
                width: 210mm;
                min-height: 297mm;
                orphans: 3;
                widows: 3;
            }
        }
        \(css)
        </style>
        </head>
        <body>
        \(html)
        </body>
        </html>
        """
    }

    /// Renders run strictly one at a time: they share the single render window and,
    /// per template, a fixed temp-file path, so overlapping renders would detach each
    /// other's web view mid-render and clobber each other's temp file.
    private var pendingRender: Task<PDFDocument, Error>?

    private func renderHTMLToPDF(_ html: String, baseURL: URL? = nil, rect: CGRect? = nil) async throws -> PDFDocument {
        let previous = pendingRender
        let render = Task {
            _ = try? await previous?.value
            return try await performRender(html, baseURL: baseURL, rect: rect)
        }
        pendingRender = render
        return try await render.value
    }

    private func performRender(_ html: String, baseURL: URL? = nil, rect: CGRect? = nil) async throws -> PDFDocument {
        // When a baseURL is provided, write HTML to a temp file and use loadFileURL
        // so WKWebView's WebContent process can access local resources (images, etc.)
        var tempFileURL: URL?
        if let baseURL {
            let fileURL = baseURL.appendingPathComponent(".harvie-render.html")
            try? html.write(to: fileURL, atomically: true, encoding: .utf8)
            tempFileURL = fileURL
        }
        defer { if let url = tempFileURL { try? FileManager.default.removeItem(at: url) } }

        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        config.suppressesIncrementalRendering = true

        // Templates are pure HTML/CSS (Mustache processed server-side) — disable
        // features we don't need to reduce WebContent sandbox probe warnings.
        let webpagePrefs = WKWebpagePreferences()
        webpagePrefs.allowsContentJavaScript = false
        config.defaultWebpagePreferences = webpagePrefs

        config.preferences.isElementFullscreenEnabled = false
        config.preferences.javaScriptCanOpenWindowsAutomatically = false

        config.allowsAirPlayForMediaPlayback = false
        config.mediaTypesRequiringUserActionForPlayback = .all

        let webView = WKWebView(
            frame: CGRect(x: 0, y: 0, width: Self.a4Width, height: Self.a4Height),
            configuration: config
        )
        webView.setValue(false, forKey: "drawsBackground")
        webView.wantsLayer = true
        renderWindow.contentView = webView

        defer { renderWindow.contentView = nil }

        return try await withCheckedThrowingContinuation { continuation in
            let delegate = PDFNavigationDelegate(webView: webView, rect: rect) { result in
                continuation.resume(with: result)
            }

            // Retain delegate via associated object — WKWebView.navigationDelegate is weak
            objc_setAssociatedObject(webView, "navDelegate", delegate, .OBJC_ASSOCIATION_RETAIN)
            webView.navigationDelegate = delegate
            delegate.startTimeout(seconds: 10)

            if let tempFileURL, let baseURL {
                webView.loadFileURL(tempFileURL, allowingReadAccessTo: baseURL)
            } else {
                webView.loadHTMLString(html, baseURL: nil)
            }
        }
    }
}

private final class PDFNavigationDelegate: NSObject, WKNavigationDelegate {
    enum PDFError: Error, LocalizedError {
        case renderingFailed
        case processTerminated
        case timeout

        var errorDescription: String? {
            switch self {
            case .renderingFailed:
                return Strings.Errors.renderingFailed
            case .processTerminated:
                return Strings.Errors.processTerminated
            case .timeout:
                return Strings.Errors.renderingTimeout
            }
        }
    }

    // weak: the web view retains this delegate via an associated object, so a
    // strong reference back would create a retain cycle and leak both per render.
    private weak var webView: WKWebView?
    private let rect: CGRect?
    private let completion: (Result<PDFDocument, Error>) -> Void
    private var hasCompleted = false

    init(webView: WKWebView, rect: CGRect? = nil, completion: @escaping (Result<PDFDocument, Error>) -> Void) {
        self.webView = webView
        self.rect = rect
        self.completion = completion
        super.init()
    }

    /// The continuation driving the render is resumed only by delegate callbacks,
    /// so the timeout must fire through the same completion path.
    func startTimeout(seconds: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
            guard let self, !self.hasCompleted else { return }
            self.hasCompleted = true
            self.webView?.stopLoading()
            logger.error("PDF render timed out after \(seconds)s")
            self.completion(.failure(PDFError.timeout))
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard !hasCompleted else { return }

        // Small delay to let the page finish layout
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.createPDF(from: webView)
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        guard !hasCompleted else { return }
        hasCompleted = true
        completion(.failure(error))
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        guard !hasCompleted else { return }
        hasCompleted = true
        logger.error("Provisional navigation failed: \(error.localizedDescription)")
        completion(.failure(error))
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        guard !hasCompleted else { return }
        hasCompleted = true
        logger.error("WebContent process terminated")
        completion(.failure(PDFError.processTerminated))
    }

    private func createPDF(from webView: WKWebView) {
        guard !hasCompleted else { return }

        let config = WKPDFConfiguration()
        if let rect {
            config.rect = rect
        }

        webView.createPDF(configuration: config) { [weak self] result in
            guard let self, !self.hasCompleted else { return }
            self.hasCompleted = true

            switch result {
            case .success(let data):
                if let document = PDFDocument(data: data) {
                    self.completion(.success(document))
                } else {
                    self.completion(.failure(PDFError.renderingFailed))
                }
            case .failure(let error):
                self.completion(.failure(error))
            }
        }
    }
}
