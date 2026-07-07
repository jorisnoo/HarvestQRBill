//
//  TemplateFileManager.swift
//  Harvie
//

import AppKit
import Foundation
import os.log
import UniformTypeIdentifiers

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "app.harvie", category: "TemplateFileManager")

enum TemplateFileManager {
    static var templatesRoot: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("Harvie/Templates")
    }

    /// Builds the canonical folder name: `<sanitized-name>-<uuid>`
    static func templateDirectory(for id: UUID, name: String) -> URL {
        let folderName = "\(sanitize(name))-\(id.uuidString)"
        return templatesRoot.appendingPathComponent(folderName)
    }

    /// Finds existing directory by UUID suffix, regardless of name.
    static func existingDirectory(for id: UUID) -> URL? {
        let fm = FileManager.default
        let root = templatesRoot
        guard let entries = try? fm.contentsOfDirectory(at: root, includingPropertiesForKeys: nil) else {
            return nil
        }
        let suffix = id.uuidString
        return entries.first { $0.lastPathComponent.hasSuffix(suffix) }
    }

    static func htmlURL(for id: UUID) -> URL? {
        existingDirectory(for: id)?.appendingPathComponent("template.html")
    }

    static func cssURL(for id: UUID) -> URL? {
        existingDirectory(for: id)?.appendingPathComponent("styles.css")
    }

    static func loadHTML(for id: UUID) -> String? {
        guard let url = htmlURL(for: id) else { return nil }
        return try? String(contentsOf: url, encoding: .utf8)
    }

    static func loadCSS(for id: UUID) -> String? {
        guard let url = cssURL(for: id) else { return nil }
        return try? String(contentsOf: url, encoding: .utf8)
    }

    static func save(html: String, css: String, for id: UUID, name: String) throws {
        let target = templateDirectory(for: id, name: name)

        // Rename existing folder if the name changed
        if let existing = existingDirectory(for: id), existing != target {
            try? FileManager.default.moveItem(at: existing, to: target)
        }

        do {
            try FileManager.default.createDirectory(at: target, withIntermediateDirectories: true)
            try html.write(to: target.appendingPathComponent("template.html"), atomically: true, encoding: .utf8)
            try css.write(to: target.appendingPathComponent("styles.css"), atomically: true, encoding: .utf8)
        } catch {
            logger.error("Failed to save template files for \(id): \(error.localizedDescription)")
            throw error
        }
    }

    static func delete(for id: UUID) {
        guard let dir = existingDirectory(for: id) else { return }
        try? FileManager.default.removeItem(at: dir)
    }

    static func filesExist(for id: UUID) -> Bool {
        existingDirectory(for: id) != nil
    }

    static func revealInFinder(for id: UUID) {
        guard let dir = existingDirectory(for: id) else { return }
        NSWorkspace.shared.activateFileViewerSelecting([dir])
    }

    static func openInEditor(for id: UUID) {
        guard let dir = existingDirectory(for: id) else { return }
        NSWorkspace.shared.open(dir)
    }

    /// Scans the templates directory for folders matching `<name>-<UUID>` that contain
    /// both `template.html` and `styles.css`, returning discovered template metadata.
    static func discoverTemplates() -> [(id: UUID, name: String)] {
        let fm = FileManager.default
        let root = templatesRoot
        guard let entries = try? fm.contentsOfDirectory(at: root, includingPropertiesForKeys: [.isDirectoryKey]) else {
            return []
        }

        var results: [(id: UUID, name: String)] = []
        let uuidLength = 36 // "550E8400-E29B-41D4-A716-446655440000"

        for entry in entries {
            let folderName = entry.lastPathComponent

            // Need at least a name, a hyphen, and a UUID
            guard folderName.count > uuidLength + 1 else { continue }

            let uuidStart = folderName.index(folderName.endIndex, offsetBy: -uuidLength)
            guard let id = UUID(uuidString: String(folderName[uuidStart...])) else { continue }

            // Verify both required files exist
            let htmlExists = fm.fileExists(atPath: entry.appendingPathComponent("template.html").path)
            let cssExists = fm.fileExists(atPath: entry.appendingPathComponent("styles.css").path)
            guard htmlExists && cssExists else { continue }

            // Derive display name: strip "-UUID" suffix, replace hyphens with spaces, capitalize words
            let prefix = folderName[..<folderName.index(before: uuidStart)] // drop the separator hyphen too
            let displayName = String(prefix)
                .replacingOccurrences(of: "-", with: " ")
                .capitalized

            results.append((id: id, name: displayName))
        }

        return results
    }

    static func revealTemplatesFolder() {
        let dir = templatesRoot
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        NSWorkspace.shared.open(dir)
    }

    // MARK: - Import / Export

    static let templateContentType = UTType("app.harvie.template") ?? .json

    struct TemplatePackage: Codable {
        let name: String
        let version: Int
        let html: String
        let css: String
    }

    static func exportTemplate(name: String, html: String, css: String, to url: URL) throws {
        let package = TemplatePackage(name: name, version: 1, html: html, css: css)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(package)
        try data.write(to: url)
    }

    static func importTemplate(from url: URL) throws -> TemplatePackage {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(TemplatePackage.self, from: data)
    }

    // MARK: - Private

    private static func sanitize(_ name: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_ "))
        let cleaned = name.unicodeScalars.filter { allowed.contains($0) }
        let result = String(String.UnicodeScalarView(cleaned))
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: " ", with: "-")
        return result.isEmpty ? "template" : result
    }
}
