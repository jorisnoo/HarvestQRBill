//
//  EstimatesViewModel+Export.swift
//  Harvie
//

import AppKit
import Foundation
import os.log
import PDFKit
import SwiftData
import UniformTypeIdentifiers

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "app.harvie", category: "EstimatesVM+Export")

extension EstimatesViewModel {

    func exportSelectedEstimates() async {
        let toExport = selectedEstimates
        guard !toExport.isEmpty else { return }

        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = Strings.Export.selectFolderMessageEstimates
        panel.prompt = Strings.Common.select

        let response = await MainActor.run { panel.runModal() }
        guard response == .OK, let folderURL = panel.url else { return }

        isExporting = true
        exportProgress = 0
        exportError = nil
        exportedCount = 0

        do {
            let credentials = try await KeychainService.shared.loadHarvestCredentials()
            let creditorInfo = try await KeychainService.shared.loadCreditorInfo()

            // Template rendering shows creditor details on the document (same rule as invoices)
            if appSettings.effectivePDFSource == .template, !creditorInfo.isValid {
                exportError = Strings.Errors.configureCreditor
                isExporting = false
                return
            }

            let total = toExport.count
            var overrideCache: [Int: ClientOverride?] = [:]

            for (index, estimate) in toExport.enumerated() {
                exportProgressMessage = Strings.Export.exportingProgress(index + 1, total, estimate.number)
                exportProgress = Double(index) / Double(total)

                let clientId = estimate.client.id
                if overrideCache[clientId] == nil {
                    overrideCache[clientId] = .some(fetchClientOverride(for: clientId))
                }
                let resolvedSettings = appSettings.resolved(with: overrideCache[clientId] ?? nil)

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
                    for: estimate,
                    credentials: credentials,
                    creditorInfo: creditorInfo,
                    template: template,
                    settings: resolvedSettings
                )

                let fileName = resolvedSettings.generateFilename(
                    invoiceNumber: estimate.number,
                    creditorName: creditorInfo.name,
                    clientName: estimate.client.name,
                    date: estimate.issueDate,
                    issueDate: estimate.issueDate,
                    dueDate: estimate.issueDate,
                    paidDate: nil
                )
                let fileURL = folderURL.appendingPathComponent(fileName)

                try await PDFService.shared.savePDF(document, to: fileURL)
                exportedCount += 1
            }

            exportProgress = 1.0
            exportProgressMessage = Strings.Export.exportComplete
            showExportSuccess = true
            Analytics.estimatesExported(count: exportedCount)
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
        return try? context.fetch(descriptor).first
    }

    private func resolveTemplate(for settings: AppSettings? = nil) async -> InvoiceTemplate? {
        let effectiveSettings = settings ?? appSettings

        if let templateId = effectiveSettings.selectedTemplateId,
           let template = await loadTemplate(id: templateId) {
            return template
        }

        guard let context = modelContext else { return nil }
        let descriptor = FetchDescriptor<InvoiceTemplate>(
            sortBy: [SortDescriptor(\.name)]
        )

        guard let fallback = try? context.fetch(descriptor).first else { return nil }

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
        for estimate: Estimate,
        credentials: HarvestCredentials,
        creditorInfo: CreditorInfo,
        template: InvoiceTemplate?,
        settings: AppSettings
    ) async throws -> PDFDocument {
        if let template {
            return try await PDFService.shared.createEstimateFromTemplate(
                estimate: estimate,
                template: template,
                creditorInfo: creditorInfo,
                credentials: credentials,
                language: settings.templateLanguage,
                labelOverrides: settings.labelOverrides,
                columnVisibility: settings.columnVisibility
            )
        } else {
            let pdfURL = try HarvestAPIService.shared.buildEstimatePDFURL(for: estimate, subdomain: credentials.subdomain)
            return try await PDFService.shared.downloadPDF(from: pdfURL)
        }
    }
}
