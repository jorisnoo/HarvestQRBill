//
//  TemplateEditorViewModel.swift
//  Harvie
//

import Combine
import Foundation
import PDFKit
import SwiftData
import SwiftUI

@Observable
@MainActor
final class TemplateEditorViewModel {
    var template: InvoiceTemplate
    var htmlContent: String
    var cssContent: String
    var name: String
    var columnVisibility: ColumnVisibility
    var isDirty = false
    var isRendering = false
    var previewHTML: String = ""
    var selectedTab: EditorTab = .html
    var error: String?
    var language: TemplateLanguage
    var labelOverrides: [String: [String: String]]?

    enum EditorTab: String, CaseIterable {
        case html = "HTML"
        case css = "CSS"
    }

    @ObservationIgnored nonisolated(unsafe) private var renderTask: Task<Void, Never>?
    @ObservationIgnored private var fileWatcher: TemplateFileWatcher?
    // Last content read from or written to disk; used to ignore watcher events
    // caused by unrelated files in the template directory (e.g. render temp files).
    @ObservationIgnored private var lastDiskHTML: String?
    @ObservationIgnored private var lastDiskCSS: String?
    private let modelContext: ModelContext

    deinit {
        renderTask?.cancel()
        fileWatcher?.stop()
    }

    init(
        template: InvoiceTemplate,
        modelContext: ModelContext,
        language: TemplateLanguage = .en,
        labelOverrides: [String: [String: String]]? = nil,
        columnVisibility: ColumnVisibility = .default
    ) {
        self.template = template
        self.htmlContent = template.resolvedHTMLContent()
        self.cssContent = template.resolvedCSSContent()
        self.lastDiskHTML = TemplateFileManager.loadHTML(for: template.id)
        self.lastDiskCSS = TemplateFileManager.loadCSS(for: template.id)
        self.name = template.name
        self.columnVisibility = columnVisibility
        self.language = language
        self.labelOverrides = labelOverrides
        self.modelContext = modelContext
        updatePreview()
        startFileWatcher()
    }

    var isBuiltIn: Bool {
        template.isBuiltIn
    }

    var baseURL: URL? {
        template.isBuiltIn ? nil : TemplateFileManager.existingDirectory(for: template.id)
    }

    func contentChanged() {
        isDirty = true
        schedulePreviewUpdate()
    }

    func save() {
        template.name = name
        template.updatedAt = Date()

        if !template.isBuiltIn {
            do {
                try TemplateFileManager.save(html: htmlContent, css: cssContent, for: template.id, name: name)
                // Clear SwiftData content — disk is source of truth
                template.htmlContent = ""
                template.cssContent = ""
                lastDiskHTML = htmlContent
                lastDiskCSS = cssContent
            } catch {
                // Disk write failed: keep the content in SwiftData so it isn't lost,
                // surface the error, and stay dirty so the user can retry.
                template.htmlContent = htmlContent
                template.cssContent = cssContent
                try? modelContext.save()
                self.error = error.localizedDescription
                return
            }
        }

        try? modelContext.save()
        isDirty = false
        error = nil

        // Restart watcher since files may have been recreated
        startFileWatcher()
    }

    func openInExternalEditor() {
        guard !template.isBuiltIn else { return }
        // Ensure files exist on disk before opening
        if !TemplateFileManager.filesExist(for: template.id) {
            try? TemplateFileManager.save(html: htmlContent, css: cssContent, for: template.id, name: name)
        }
        TemplateFileManager.openInEditor(for: template.id)
    }

    func revealInFinder() {
        guard !template.isBuiltIn else { return }
        if !TemplateFileManager.filesExist(for: template.id) {
            try? TemplateFileManager.save(html: htmlContent, css: cssContent, for: template.id, name: name)
        }
        TemplateFileManager.revealInFinder(for: template.id)
    }

    func insertVariable(_ variable: String) {
        let token = "{{\(variable)}}"
        NotificationCenter.default.post(name: .insertTemplateVariable, object: token)
    }

    private func startFileWatcher() {
        fileWatcher?.stop()
        guard !template.isBuiltIn else { return }

        let dir = TemplateFileManager.existingDirectory(for: template.id)
            ?? TemplateFileManager.templateDirectory(for: template.id, name: name)
        fileWatcher = TemplateFileWatcher { [weak self] in
            self?.reloadFromDisk()
        }
        fileWatcher?.watch(directory: dir)
    }

    private func reloadFromDisk() {
        guard !template.isBuiltIn else { return }
        let diskHTML = TemplateFileManager.loadHTML(for: template.id)
        let diskCSS = TemplateFileManager.loadCSS(for: template.id)

        // Directory events also fire for unrelated files (e.g. transient render files);
        // only reload — and discard unsaved edits — when the watched files actually changed.
        guard diskHTML != lastDiskHTML || diskCSS != lastDiskCSS else { return }

        if let diskHTML {
            htmlContent = diskHTML
            lastDiskHTML = diskHTML
        }
        if let diskCSS {
            cssContent = diskCSS
            lastDiskCSS = diskCSS
        }
        isDirty = false
        updatePreview()
    }

    private func schedulePreviewUpdate() {
        renderTask?.cancel()
        renderTask = Task {
            try? await Task.sleep(for: .milliseconds(300))

            guard !Task.isCancelled else { return }

            updatePreview()
        }
    }

    func updatePreview() {
        var context = TemplateContext.sampleDictionary()
        context["labels"] = language.resolvedLabels(overrides: labelOverrides)
        if let userLogo = LogoStorage.dataURI() {
            var creditor = context["creditor"] as! [String: Any]
            creditor["logo"] = userLogo
            creditor["hasLogo"] = true
            context["creditor"] = creditor
        }
        let processedHTML = TemplateEngine.render(htmlContent, with: context)
        let css = cssContent + "\n" + columnVisibility.cssVariables()
        previewHTML = Self.buildPreviewDocument(html: processedHTML, css: css)
    }

    static func buildPreviewDocument(html: String, css: String) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="UTF-8">
        <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body {
            width: 210mm;
            min-height: 297mm;
            font-family: -apple-system, BlinkMacSystemFont, 'Helvetica Neue', sans-serif;
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
}
