//
//  TemplateListView.swift
//  Harvie
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct TemplateListView: View {
    /// When non-nil, double-clicking a template selects it as the active template.
    var activeTemplateId: Binding<UUID?>?
    var language: TemplateLanguage = .en
    var labelOverrides: [String: [String: String]]?
    var columnVisibility: ColumnVisibility = .default

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \InvoiceTemplate.createdAt) private var templates: [InvoiceTemplate]
    @State private var selectedTemplate: InvoiceTemplate?
    @State private var showDeleteConfirmation = false
    @State private var templateToDelete: InvoiceTemplate?
    @State private var editorControllers: [NSWindowController] = []
    @State private var previewControllers: [NSWindowController] = []
    @State private var importError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List(selection: $selectedTemplate) {
                ForEach(templates) { template in
                    TemplateRow(
                        template: template,
                        isActive: activeTemplateId?.wrappedValue == template.id
                    )
                    .tag(template)
                    .onDoubleClick {
                        if activeTemplateId != nil {
                            activeTemplateId?.wrappedValue = template.id
                        } else {
                            openEditor(for: template)
                        }
                    }
                    .contextMenu {
                        templateContextMenu(for: template)
                    }
                }
            }
            .listStyle(.bordered)
            .frame(minHeight: 200)

            HStack(spacing: 8) {
                Button {
                    createTemplate()
                } label: {
                    Image(systemName: "plus")
                        .frame(height: 16)
                }
                .help(Strings.Templates.newTemplate)

                Button {
                    guard let selected = selectedTemplate else { return }
                    duplicateTemplate(selected)
                } label: {
                    Image(systemName: "doc.on.doc")
                        .frame(height: 16)
                }
                .disabled(selectedTemplate == nil)
                .help(Strings.Templates.duplicateTemplate)

                Button {
                    guard let selected = selectedTemplate else { return }

                    if selected.isBuiltIn {
                        return
                    }

                    templateToDelete = selected
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "minus")
                        .frame(height: 16)
                }
                .disabled(selectedTemplate == nil || selectedTemplate?.isBuiltIn == true)
                .help(Strings.Templates.deleteTemplate)

                Spacer()

                Button {
                    importTemplate()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .frame(height: 16)
                }
                .help(Strings.Templates.importTemplate)

                Button {
                    guard let selected = selectedTemplate else { return }
                    exportTemplate(selected)
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .frame(height: 16)
                }
                .disabled(selectedTemplate == nil)
                .help(Strings.Templates.exportTemplate)

                Button {
                    TemplateFileManager.revealTemplatesFolder()
                } label: {
                    Image(systemName: "folder")
                        .frame(height: 16)
                }
                .help(Strings.Templates.revealTemplatesFolder)

                Button {
                    guard let selected = selectedTemplate else { return }
                    Task { await openPreview(for: selected) }
                } label: {
                    Text(Strings.Common.preview).frame(height: 16)
                }
                .disabled(selectedTemplate == nil)

                Button {
                    guard let selected = selectedTemplate else { return }
                    openEditor(for: selected)
                } label: {
                    Text(Strings.Common.edit).frame(height: 16)
                }
                .disabled(selectedTemplate == nil)
            }
            .controlSize(.small)
            .padding(8)
        }
        .alert(Strings.Templates.deleteTemplateTitle, isPresented: $showDeleteConfirmation) {
            Button(Strings.Common.cancel, role: .cancel) { }
            Button(Strings.Common.delete, role: .destructive) {
                if let template = templateToDelete {
                    deleteTemplate(template)
                }
            }
        } message: {
            Text(Strings.Templates.deleteConfirmation(templateToDelete?.name ?? ""))
        }
        .alert(Strings.Templates.importErrorTitle, isPresented: Binding(
            get: { importError != nil },
            set: { if !$0 { importError = nil } }
        )) {
            Button(Strings.Common.ok) { importError = nil }
        } message: {
            Text(importError ?? "")
        }
    }

    @ViewBuilder
    private func templateContextMenu(for template: InvoiceTemplate) -> some View {
        Button(Strings.Common.preview) {
            Task { await openPreview(for: template) }
        }

        Button(Strings.Common.edit) {
            openEditor(for: template)
        }

        Button(Strings.Templates.duplicate) {
            duplicateTemplate(template)
        }

        Button(Strings.Templates.export) {
            exportTemplate(template)
        }

        if !template.isBuiltIn {
            Divider()

            Button(Strings.Templates.openInExternalEditor) {
                if !TemplateFileManager.filesExist(for: template.id) {
                    try? TemplateFileManager.save(
                        html: template.resolvedHTMLContent(),
                        css: template.resolvedCSSContent(),
                        for: template.id,
                        name: template.name
                    )
                }
                TemplateFileManager.openInEditor(for: template.id)
            }

            Button(Strings.Templates.revealInFinder) {
                if !TemplateFileManager.filesExist(for: template.id) {
                    try? TemplateFileManager.save(
                        html: template.resolvedHTMLContent(),
                        css: template.resolvedCSSContent(),
                        for: template.id,
                        name: template.name
                    )
                }
                TemplateFileManager.revealInFinder(for: template.id)
            }

            Divider()

            Button(Strings.Common.delete, role: .destructive) {
                templateToDelete = template
                showDeleteConfirmation = true
            }
        }
    }

    private func createTemplate() {
        let html = "<div class=\"invoice\">\n    <h1>{{creditor.name}}</h1>\n    <p>Invoice {{invoice.number}}</p>\n</div>"
        let css = ".invoice {\n    padding: 40px;\n    font-family: sans-serif;\n}"

        let template = InvoiceTemplate(
            name: Strings.Templates.untitledTemplate,
            htmlContent: html,
            cssContent: css
        )
        modelContext.insert(template)
        try? modelContext.save()

        do {
            try TemplateFileManager.save(html: html, css: css, for: template.id, name: template.name)
            // Clear SwiftData content — disk is source of truth
            template.htmlContent = ""
            template.cssContent = ""
            try? modelContext.save()
        } catch {
            // Keep the content in SwiftData as fallback; migration retries the disk write.
        }

        selectedTemplate = template
        openEditor(for: template)
    }

    private func duplicateTemplate(_ template: InvoiceTemplate) {
        let resolvedHTML = template.resolvedHTMLContent()
        let resolvedCSS = template.resolvedCSSContent()

        let copy = template.duplicate()
        modelContext.insert(copy)
        try? modelContext.save()

        if !copy.isBuiltIn {
            do {
                try TemplateFileManager.save(html: resolvedHTML, css: resolvedCSS, for: copy.id, name: copy.name)
                // Clear SwiftData content — disk is source of truth
                copy.htmlContent = ""
                copy.cssContent = ""
                try? modelContext.save()
            } catch {
                // Keep the content in SwiftData as fallback; migration retries the disk write.
            }
        }

        selectedTemplate = copy
    }

    private func exportTemplate(_ template: InvoiceTemplate) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [TemplateFileManager.templateContentType]
        panel.nameFieldStringValue = template.name
        panel.prompt = Strings.Templates.export

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            try TemplateFileManager.exportTemplate(
                name: template.name,
                html: template.resolvedHTMLContent(),
                css: template.resolvedCSSContent(),
                to: url
            )
        } catch {
            importError = error.localizedDescription
        }
    }

    private func importTemplate() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [TemplateFileManager.templateContentType]
        panel.message = Strings.Templates.importMessage

        guard panel.runModal() == .OK, !panel.urls.isEmpty else { return }

        for url in panel.urls {
            do {
                let package = try TemplateFileManager.importTemplate(from: url)

                let template = InvoiceTemplate(
                    name: package.name,
                    htmlContent: package.html,
                    cssContent: package.css
                )
                modelContext.insert(template)
                try modelContext.save()

                do {
                    try TemplateFileManager.save(
                        html: package.html,
                        css: package.css,
                        for: template.id,
                        name: template.name
                    )
                    // Clear SwiftData content — disk is source of truth
                    template.htmlContent = ""
                    template.cssContent = ""
                    try? modelContext.save()
                } catch {
                    // Keep the content in SwiftData as fallback; migration retries the disk write.
                }

                selectedTemplate = template
            } catch {
                importError = error.localizedDescription
            }
        }
    }

    private func deleteTemplate(_ template: InvoiceTemplate) {
        if selectedTemplate == template {
            selectedTemplate = nil
        }
        TemplateFileManager.delete(for: template.id)
        modelContext.delete(template)
        try? modelContext.save()
    }

    private func openEditor(for template: InvoiceTemplate) {
        editorControllers.removeAll { $0.window == nil || !$0.window!.isVisible }

        let viewModel = TemplateEditorViewModel(
            template: template, modelContext: modelContext,
            language: language, labelOverrides: labelOverrides,
            columnVisibility: columnVisibility
        )
        let editorView = TemplateEditorView(viewModel: viewModel)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1200, height: 800),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = template.isBuiltIn ? Strings.Templates.builtInWindowTitle(template.name) : template.name
        window.contentView = NSHostingView(rootView: editorView)

        let controller = NSWindowController(window: window)
        editorControllers.append(controller)
        controller.showWindow(nil)
        window.center()
    }

    private func openPreview(for template: InvoiceTemplate) async {
        previewControllers.removeAll { $0.window == nil || !$0.window!.isVisible }

        var context = TemplateContext.sampleDictionary()
        context["labels"] = language.resolvedLabels(overrides: labelOverrides)
        var creditor = context["creditor"] as! [String: Any]

        if let info = try? await KeychainService.shared.loadCreditorInfo(), info.isValid {
            creditor["name"] = info.name
            creditor["iban"] = info.iban
            creditor["street"] = info.streetName
            creditor["buildingNumber"] = info.buildingNumber
            creditor["postalCode"] = info.postalCode
            creditor["town"] = info.town
            creditor["country"] = info.country
        }

        if let userLogo = LogoStorage.dataURI() {
            creditor["logo"] = userLogo
            creditor["hasLogo"] = true
        }

        context["creditor"] = creditor

        let processedHTML = TemplateEngine.render(template.resolvedHTMLContent(), with: context)
        let css = template.resolvedCSSContent() + "\n" + columnVisibility.cssVariables()
        let html = TemplateEditorViewModel.buildPreviewDocument(html: processedHTML, css: css)

        let baseURL = template.isBuiltIn ? nil : TemplateFileManager.existingDirectory(for: template.id)
        let previewView = TemplatePreviewView(html: html, baseURL: baseURL)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 900),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = Strings.Templates.previewWindowTitle(template.name)
        window.contentView = NSHostingView(rootView: previewView)

        let controller = NSWindowController(window: window)
        previewControllers.append(controller)
        controller.showWindow(nil)
        window.center()
    }
}

private struct TemplateRow: View {
    let template: InvoiceTemplate
    var isActive: Bool = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(template.name)
                        .fontWeight(.medium)

                    if template.isBuiltIn {
                        Text(Strings.Templates.builtIn)
                            .font(.caption2)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(.quaternary)
                            .clipShape(Capsule())
                    }
                }

                Text(Strings.Templates.updatedAt(template.updatedAt.formatted(date: .abbreviated, time: .shortened)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isActive {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.tint)
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Double Click Modifier

private struct OnDoubleClickModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content.overlay {
            DoubleClickOverlay(action: action)
        }
    }
}

private struct DoubleClickOverlay: NSViewRepresentable {
    let action: () -> Void

    func makeNSView(context: Context) -> NSView {
        let view = DoubleClickView()
        view.action = action
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        (nsView as? DoubleClickView)?.action = action
    }

    private class DoubleClickView: NSView {
        var action: (() -> Void)?

        override func mouseDown(with event: NSEvent) {
            super.mouseDown(with: event)
            if event.clickCount == 2 {
                action?()
            }
        }
    }
}

extension View {
    func onDoubleClick(perform action: @escaping () -> Void) -> some View {
        modifier(OnDoubleClickModifier(action: action))
    }
}
