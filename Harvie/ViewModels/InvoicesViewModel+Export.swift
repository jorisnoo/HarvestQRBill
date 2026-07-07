//
//  InvoicesViewModel+Export.swift
//  Harvie
//

import AppKit
import Foundation
import os.log
import PDFKit
import SwiftData

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "app.harvie", category: "InvoicesVM+Export")

extension InvoicesViewModel {

    func exportSelectedInvoices(withQRBill: Bool) async {
        let invoicesToExport = selectedInvoices
        guard !invoicesToExport.isEmpty else { return }

        // Show folder picker
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = Strings.Export.selectFolderMessage
        panel.prompt = Strings.Common.select

        let response = await MainActor.run {
            panel.runModal()
        }

        guard response == .OK, let folderURL = panel.url else { return }

        isExporting = true
        exportProgress = 0
        exportError = nil
        exportedCount = 0

        do {
            let credentials = try await KeychainService.shared.loadHarvestCredentials()
            let creditorInfo = try await KeychainService.shared.loadCreditorInfo()

            let requiresCreditorInfo = withQRBill || appSettings.effectivePDFSource == .template
            if requiresCreditorInfo, !creditorInfo.isValid {
                exportError = Strings.Errors.configureCreditor
                isExporting = false
                return
            }

            let total = invoicesToExport.count
            var overrideCache: [Int: ClientOverride?] = [:]

            for (index, invoice) in invoicesToExport.enumerated() {
                exportProgressMessage = Strings.Export.exportingProgress(index + 1, total, invoice.number)
                exportProgress = Double(index) / Double(total)

                let clientId = invoice.client.id
                if overrideCache[clientId] == nil {
                    overrideCache[clientId] = .some(fetchClientOverride(for: clientId))
                }
                let resolvedSettings = appSettings.resolved(with: overrideCache[clientId] ?? nil)

                // Resolve template per-invoice (clients may have different settings)
                var template: InvoiceTemplate?
                if resolvedSettings.effectivePDFSource == .template {
                    guard let loaded = await resolveTemplate(for: resolvedSettings) else {
                        exportError = Strings.Errors.noTemplateSelected
                        isExporting = false
                        return
                    }
                    template = loaded
                }

                let document = try await generatePDF(
                    for: invoice,
                    withQRBill: withQRBill,
                    credentials: credentials,
                    creditorInfo: creditorInfo,
                    template: template,
                    settings: resolvedSettings
                )

                let date: Date = switch sortOption {
                case .issueDate, .dueDate:
                    invoice.issueDate
                case .paidDate:
                    invoice.effectivePaidDate ?? invoice.issueDate
                }

                let fileName = resolvedSettings.generateFilename(
                    invoiceNumber: invoice.number,
                    creditorName: creditorInfo.name,
                    clientName: invoice.client.name,
                    date: date,
                    issueDate: invoice.issueDate,
                    dueDate: invoice.dueDate,
                    paidDate: invoice.effectivePaidDate
                )
                let fileURL = folderURL.appendingPathComponent(fileName)

                try await PDFService.shared.savePDF(document, to: fileURL)
                exportedCount += 1
            }

            exportProgress = 1.0
            exportProgressMessage = Strings.Export.exportComplete
            showExportSuccess = true
            Analytics.batchExportCompleted(count: exportedCount, withQRBill: withQRBill)
        } catch {
            exportError = error.localizedDescription
        }

        isExporting = false
    }

    func loadTemplate(id: UUID) async -> InvoiceTemplate? {
        guard let context = modelContext else { return nil }

        let descriptor = FetchDescriptor<InvoiceTemplate>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            return try context.fetch(descriptor).first
        } catch {
            #if DEBUG
            logger.error("Failed to load template: \(error.localizedDescription)")
            #endif
            return nil
        }
    }

    /// Resolves the selected template, falling back to the first available template
    /// if the selected one no longer exists (e.g. after a template was deleted or re-seeded).
    private func resolveTemplate(for settings: AppSettings? = nil) async -> InvoiceTemplate? {
        let effectiveSettings = settings ?? appSettings

        // Try the explicitly selected template first
        if let templateId = effectiveSettings.selectedTemplateId,
           let template = await loadTemplate(id: templateId) {
            return template
        }

        // Fall back to the first available template
        guard let context = modelContext else { return nil }
        let descriptor = FetchDescriptor<InvoiceTemplate>(
            sortBy: [SortDescriptor(\.name)]
        )

        guard let fallback = try? context.fetch(descriptor).first else { return nil }

        // Update the setting so future calls don't need the fallback
        appSettings.selectedTemplateId = fallback.id
        return fallback
    }

    func fetchClientOverride(for clientId: Int) -> ClientOverride? {
        guard let context = modelContext else { return nil }
        let descriptor = FetchDescriptor<ClientOverride>(
            predicate: #Predicate { $0.clientId == clientId }
        )
        return try? context.fetch(descriptor).first
    }

    // MARK: - PDF Generation

    func generatePDF(
        for invoice: Invoice,
        withQRBill: Bool,
        credentials: HarvestCredentials,
        creditorInfo: CreditorInfo,
        template: InvoiceTemplate?,
        settings: AppSettings
    ) async throws -> PDFDocument {
        if let template {
            return try await PDFService.shared.createInvoiceFromTemplate(
                invoice: invoice,
                template: template,
                creditorInfo: creditorInfo,
                credentials: credentials,
                language: settings.templateLanguage,
                labelOverrides: settings.labelOverrides,
                paidMarkStyle: settings.paidMarkStyle,
                columnVisibility: settings.columnVisibility,
                includeQRBill: withQRBill
            )
        }

        if withQRBill {
            return try await PDFService.shared.createInvoiceWithQRBill(
                invoice: invoice,
                credentials: credentials,
                creditorInfo: creditorInfo,
                language: settings.templateLanguage,
                labelOverrides: settings.labelOverrides,
                paidMarkStyle: settings.paidMarkStyle
            )
        }

        return try await PDFService.shared.createInvoiceFromHarvest(
            invoice: invoice,
            credentials: credentials,
            language: settings.templateLanguage,
            paidMarkStyle: settings.paidMarkStyle
        )
    }
}
