//
//  SettingsViewModel.swift
//  Harvie
//

import Foundation
import os.log
import SwiftUI
import UniformTypeIdentifiers

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "app.harvie", category: "Settings")

@Observable
@MainActor
final class SettingsViewModel {
    var harvestCredentials: HarvestCredentials = HarvestCredentials(
        accessToken: "",
        accountId: "",
        subdomain: ""
    )

    var creditorInfo: CreditorInfo = .empty
    var appSettings: AppSettings = .default

    var logoImage: NSImage?

    var isTestingConnection = false
    var connectionTestResult: ConnectionTestResult?
    var saveError: String?

    enum ConnectionTestResult: Equatable {
        case success
        case failure(String)
    }

    private let keychainService = KeychainService.shared
    private let apiService = HarvestAPIService.shared
    private var autoSaveTask: Task<Void, Never>?
    private var lastSavedCredentials: HarvestCredentials?
    private var lastSavedDemoMode: Bool?

    func loadSettings() async {
        harvestCredentials = (try? await keychainService.loadHarvestCredentials())
            ?? HarvestCredentials(accessToken: "", accountId: "", subdomain: "")
        creditorInfo = (try? await keychainService.loadCreditorInfo()) ?? .empty
        appSettings = AppSettingsStorage.load()
        logoImage = LogoStorage.loadImage()

        lastSavedCredentials = harvestCredentials
        lastSavedDemoMode = appSettings.isDemoMode
    }

    static let settingsSavedNotification = Notification.Name("SettingsViewModelDidSaveSettings")

    func autoSave() {
        autoSaveTask?.cancel()
        autoSaveTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            await saveSettings()
        }
    }

    func saveImmediately() {
        autoSaveTask?.cancel()
        autoSaveTask = Task { await saveSettings() }
    }

    private func saveSettings() async {
        let needsAPIRefresh = harvestCredentials != lastSavedCredentials || appSettings.isDemoMode != lastSavedDemoMode

        do {
            try await keychainService.saveHarvestCredentials(harvestCredentials)
            try await keychainService.saveCreditorInfo(creditorInfo)
            AppSettingsStorage.save(appSettings)
            Analytics.settingsSaved()

            lastSavedCredentials = harvestCredentials
            lastSavedDemoMode = appSettings.isDemoMode
            saveError = nil

            NotificationCenter.default.post(
                name: Self.settingsSavedNotification,
                object: nil,
                userInfo: ["needsAPIRefresh": needsAPIRefresh]
            )
        } catch {
            logger.error("Failed to save settings: \(error.localizedDescription)")
            saveError = error.localizedDescription
        }
    }

    func testConnection() async {
        guard harvestCredentials.canTestConnection else {
            connectionTestResult = .failure(Strings.Errors.fillCredentials)
            return
        }

        isTestingConnection = true
        connectionTestResult = nil

        do {
            let success = try await apiService.testConnection(credentials: harvestCredentials)
            if success {
                let company = try await apiService.fetchCompany(credentials: harvestCredentials)
                harvestCredentials.subdomain = company.subdomain
                connectionTestResult = .success
                Analytics.harvestConnected()
            } else {
                connectionTestResult = .failure(Strings.Errors.connectionFailed)
            }
        } catch let apiError as HarvestAPIService.APIError {
            // Use the sanitized error descriptions from APIError
            connectionTestResult = .failure(apiError.localizedDescription)
        } catch {
            #if DEBUG
            logger.error("Connection test failed: \(error.localizedDescription)")
            #endif
            connectionTestResult = .failure(Strings.Errors.connectionFailedNetwork)
        }

        isTestingConnection = false
    }

    func selectLogo() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.png, .jpeg, .gif, .tiff]
        panel.message = Strings.Export.selectLogoMessage
        panel.prompt = Strings.Export.choosePrompt

        guard panel.runModal() == .OK, let url = panel.url,
              let image = NSImage(contentsOf: url) else { return }

        do {
            try LogoStorage.save(image)
            logoImage = LogoStorage.loadImage()
        } catch {
            logger.error("Failed to save logo: \(error.localizedDescription)")
        }
    }

    func removeLogo() {
        LogoStorage.delete()
        logoImage = nil
    }

    func selectDownloadFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = Strings.Export.selectFolderForDownloads
        panel.prompt = Strings.Common.select

        if panel.runModal() == .OK, let url = panel.url {
            appSettings.defaultDownloadPath = url.path
            // Create security-scoped bookmark for sandboxed access
            if let bookmarkData = try? url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            ) {
                appSettings.downloadBookmarkData = bookmarkData
            }
        }
    }
}
