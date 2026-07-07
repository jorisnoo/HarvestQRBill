//
//  TemplateSeeder.swift
//  Harvie
//

import Foundation
import SwiftData
import os.log

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "app.harvie", category: "TemplateSeeder")

struct TemplateSeeder {
    struct BuiltInTemplate {
        let name: String
        let htmlFile: String
        let cssFile: String
    }

    static let builtInTemplates = [
        BuiltInTemplate(name: "Modern", htmlFile: "modern", cssFile: "modern"),
        BuiltInTemplate(name: "Classic", htmlFile: "classic", cssFile: "classic"),
        BuiltInTemplate(name: "Minimal", htmlFile: "minimal", cssFile: "minimal")
    ]

    /// Templates copied to the user's templates folder on first launch and then owned by
    /// the user — editable, deletable, never re-seeded once the flag below is set.
    static let starterTemplates = [
        BuiltInTemplate(name: "Funky", htmlFile: "funky", cssFile: "funky"),
        BuiltInTemplate(name: "Neon Noir", htmlFile: "neon-noir", cssFile: "neon-noir")
    ]

    private static let starterSeededDefaultsKey = "harvie.starterTemplatesSeeded.v1"

    @MainActor
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<InvoiceTemplate>(
            predicate: #Predicate { $0.isBuiltIn == true }
        )
        let existingTemplates = (try? context.fetch(descriptor)) ?? []

        if existingTemplates.isEmpty {
            for builtIn in builtInTemplates {
                let html = loadResource(named: builtIn.htmlFile, extension: "html") ?? ""
                let css = loadResource(named: builtIn.cssFile, extension: "css") ?? ""

                let template = InvoiceTemplate(
                    name: builtIn.name,
                    htmlContent: html,
                    cssContent: css,
                    isBuiltIn: true
                )
                context.insert(template)
            }

            #if DEBUG
            logger.debug("Seeded \(builtInTemplates.count) built-in templates")
            #endif
        } else {
            refreshBuiltInTemplates(existingTemplates, context: context)
        }

        seedStarterTemplatesIfNeeded()
        migrateUserTemplatesToDisk(context: context)
        synchronizeDiskTemplates(context: context)
        seedVariablesReference()
        try? context.save()
    }

    /// Copies starter templates to the user's templates folder once per install. After
    /// seeding, they live as ordinary user templates on disk — `synchronizeDiskTemplates`
    /// picks them up. Deleting one in-app won't bring it back on the next launch.
    private static func seedStarterTemplatesIfNeeded() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: starterSeededDefaultsKey) else { return }

        let fm = FileManager.default
        let root = TemplateFileManager.templatesRoot
        try? fm.createDirectory(at: root, withIntermediateDirectories: true)

        let existingFolders = (try? fm.contentsOfDirectory(atPath: root.path)) ?? []

        for starter in starterTemplates {
            // Skip if a folder for this starter already exists (e.g. user had it before this version).
            let prefix = sanitizeFolderName(starter.name) + "-"
            if existingFolders.contains(where: { $0.hasPrefix(prefix) }) {
                continue
            }

            guard let html = loadResource(named: starter.htmlFile, extension: "html"),
                  let css = loadResource(named: starter.cssFile, extension: "css") else {
                logger.warning("Starter template resources missing for \(starter.name); skipping")
                continue
            }

            try? TemplateFileManager.save(html: html, css: css, for: UUID(), name: starter.name)

            #if DEBUG
            logger.debug("Seeded starter template '\(starter.name)'")
            #endif
        }

        defaults.set(true, forKey: starterSeededDefaultsKey)
    }

    /// Mirrors the folder-name sanitization used by `TemplateFileManager` for collision checks.
    private static func sanitizeFolderName(_ name: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_ "))
        let cleaned = name.unicodeScalars.filter { allowed.contains($0) }
        return String(String.UnicodeScalarView(cleaned))
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: " ", with: "-")
    }

    /// One-time migration: for user templates with content in SwiftData but no files on disk,
    /// write content to disk and clear the SwiftData fields.
    @MainActor
    private static func migrateUserTemplatesToDisk(context: ModelContext) {
        let descriptor = FetchDescriptor<InvoiceTemplate>(
            predicate: #Predicate { $0.isBuiltIn == false }
        )
        guard let userTemplates = try? context.fetch(descriptor) else { return }

        for template in userTemplates {
            let hasContent = !template.htmlContent.isEmpty || !template.cssContent.isEmpty
            let hasFiles = TemplateFileManager.filesExist(for: template.id)

            if hasContent && !hasFiles {
                do {
                    try TemplateFileManager.save(
                        html: template.htmlContent,
                        css: template.cssContent,
                        for: template.id,
                        name: template.name
                    )
                    template.htmlContent = ""
                    template.cssContent = ""
                } catch {
                    // Keep the content in SwiftData; migration retries on next launch.
                    continue
                }

                #if DEBUG
                logger.debug("Migrated user template '\(template.name)' to disk")
                #endif
            }
        }
    }

    /// Discovers template folders on disk and creates/removes SwiftData entries to match.
    @MainActor
    private static func synchronizeDiskTemplates(context: ModelContext) {
        let discovered = TemplateFileManager.discoverTemplates()

        let descriptor = FetchDescriptor<InvoiceTemplate>(
            predicate: #Predicate { $0.isBuiltIn == false }
        )
        let existing = (try? context.fetch(descriptor)) ?? []
        let existingIDs = Set(existing.map(\.id))

        // Create entries for newly discovered templates
        for entry in discovered where !existingIDs.contains(entry.id) {
            let template = InvoiceTemplate(
                id: entry.id,
                name: entry.name,
                htmlContent: "",
                cssContent: "",
                isBuiltIn: false
            )
            context.insert(template)

            #if DEBUG
            logger.debug("Auto-discovered template '\(entry.name)' from disk")
            #endif
        }

        // Remove orphaned SwiftData entries whose folders no longer exist on disk.
        // Entries that still carry content in SwiftData are pending disk migration
        // (e.g. after a failed write), not orphaned — keep them.
        let discoveredIDs = Set(discovered.map(\.id))
        for template in existing where !discoveredIDs.contains(template.id) {
            guard template.htmlContent.isEmpty && template.cssContent.isEmpty else { continue }
            context.delete(template)

            #if DEBUG
            logger.debug("Removed orphaned template '\(template.name)' (folder deleted from disk)")
            #endif
        }
    }

    /// Copies the variables reference HTML from the app bundle to the user's templates directory.
    /// Overwrites on every launch to keep it current with new releases.
    private static func seedVariablesReference() {
        guard let sourceURL = Bundle.main.url(forResource: "variables-reference", withExtension: "html", subdirectory: "Templates")
                ?? Bundle.main.url(forResource: "variables-reference", withExtension: "html") else {
            #if DEBUG
            logger.warning("variables-reference.html not found in bundle")
            #endif
            return
        }

        let dest = TemplateFileManager.templatesRoot.appendingPathComponent("variables-reference.html")
        do {
            try FileManager.default.createDirectory(at: dest.deletingLastPathComponent(), withIntermediateDirectories: true)
            let content = try String(contentsOf: sourceURL, encoding: .utf8)
            try content.write(to: dest, atomically: true, encoding: .utf8)
        } catch {
            logger.error("Failed to seed variables reference: \(error.localizedDescription)")
        }
    }

    private static func refreshBuiltInTemplates(_ templates: [InvoiceTemplate], context: ModelContext) {
        let existingNames = Set(templates.map(\.name))
        let validNames = Set(builtInTemplates.map(\.name))

        // Remove stale built-in entries no longer in the canonical list
        for template in templates where !validNames.contains(template.name) {
            context.delete(template)

            #if DEBUG
            logger.debug("Removed stale built-in template: \(template.name)")
            #endif
        }

        for template in templates {
            guard let builtIn = builtInTemplates.first(where: { $0.name == template.name }) else {
                continue
            }

            if let html = loadResource(named: builtIn.htmlFile, extension: "html") {
                template.htmlContent = html
            }

            if let css = loadResource(named: builtIn.cssFile, extension: "css") {
                template.cssContent = css
            }

            template.updatedAt = Date()
        }

        // Insert any new built-in templates not yet in the database
        for builtIn in builtInTemplates where !existingNames.contains(builtIn.name) {
            let html = loadResource(named: builtIn.htmlFile, extension: "html") ?? ""
            let css = loadResource(named: builtIn.cssFile, extension: "css") ?? ""

            let template = InvoiceTemplate(
                name: builtIn.name,
                htmlContent: html,
                cssContent: css,
                isBuiltIn: true
            )
            context.insert(template)

            #if DEBUG
            logger.debug("Seeded new built-in template: \(builtIn.name)")
            #endif
        }

        #if DEBUG
        logger.debug("Refreshed \(templates.count) built-in templates from bundle")
        #endif
    }

    private static func loadResource(named name: String, extension ext: String) -> String? {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Templates") else {
            // Try without subdirectory (flat bundle)
            guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
                #if DEBUG
                logger.warning("Template resource not found: \(name).\(ext)")
                #endif
                return nil
            }
            return try? String(contentsOf: url, encoding: .utf8)
        }
        return try? String(contentsOf: url, encoding: .utf8)
    }
}
