//
//  InvoiceFileSaver.swift
//  Harvie
//

import AppKit
import os.log
import PDFKit
import UniformTypeIdentifiers

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "app.harvie", category: "FileSaver")

@MainActor
enum InvoiceFileSaver {

    enum SaveResult {
        case saved(path: String)
        case cancelled
    }

    static func save(
        _ document: PDFDocument,
        fileName: String,
        settings: AppSettings,
        pdfService: PDFService
    ) async throws -> SaveResult {
        if settings.downloadBehavior == .useDefaultFolder,
           let folderURL = settings.downloadURL {
            let hasAccess = folderURL.startAccessingSecurityScopedResource()

            let fileURL = folderURL.appendingPathComponent(fileName)

            guard isValidPath(fileURL, within: folderURL) else {
                if hasAccess { folderURL.stopAccessingSecurityScopedResource() }
                return try await showSavePanel(for: document, suggestedName: "invoice.pdf", pdfService: pdfService)
            }

            var finalURL = fileURL
            var counter = 1
            let baseName = fileName.lowercased().hasSuffix(".pdf") ? String(fileName.dropLast(4)) : fileName

            while FileManager.default.fileExists(atPath: finalURL.path) {
                let numberedName = "\(baseName)_\(counter).pdf"
                finalURL = folderURL.appendingPathComponent(numberedName)
                guard isValidPath(finalURL, within: folderURL) else {
                    if hasAccess { folderURL.stopAccessingSecurityScopedResource() }
                    return try await showSavePanel(for: document, suggestedName: "invoice.pdf", pdfService: pdfService)
                }
                counter += 1
            }

            let success = document.write(to: finalURL)

            if hasAccess { folderURL.stopAccessingSecurityScopedResource() }

            if success {
                Analytics.pdfExported(method: "direct")
                return .saved(path: finalURL.path)
            }
        }

        return try await showSavePanel(for: document, suggestedName: fileName, pdfService: pdfService)
    }

    static func showSavePanel(
        for document: PDFDocument,
        suggestedName: String,
        pdfService: PDFService
    ) async throws -> SaveResult {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        savePanel.nameFieldStringValue = suggestedName
        savePanel.title = "Save Invoice with QR Bill"

        let response: NSApplication.ModalResponse = await withCheckedContinuation { continuation in
            savePanel.begin { response in
                continuation.resume(returning: response)
            }
        }

        guard response == .OK, let url = savePanel.url else {
            return .cancelled
        }

        try await pdfService.savePDF(document, to: url)
        Analytics.pdfExported(method: "save_panel")
        return .saved(path: url.path)
    }

    static func sanitizeFilename(_ filename: String) -> String {
        var sanitized = filename
            .replacingOccurrences(of: "..", with: "")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: "\\", with: "-")
            .replacingOccurrences(of: ":", with: "-")

        while sanitized.hasPrefix(".") || sanitized.hasPrefix("-") {
            sanitized = String(sanitized.dropFirst())
        }

        if !sanitized.lowercased().hasSuffix(".pdf") {
            sanitized += ".pdf"
        }

        return sanitized.isEmpty ? "invoice.pdf" : sanitized
    }

    static func isValidPath(_ fileURL: URL, within folderURL: URL) -> Bool {
        let resolvedFile = fileURL.standardizedFileURL.path
        let resolvedFolder = folderURL.standardizedFileURL.path

        return resolvedFile.hasPrefix(resolvedFolder + "/") || resolvedFile.hasPrefix(resolvedFolder)
    }
}
