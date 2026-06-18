//
//  SettingsView.swift
//  Harvie
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        TabView {
            HarvestSettings(viewModel: viewModel)
                .tabItem { Label(Strings.Settings.harvest, systemImage: "cloud") }

            QRBillSettings(viewModel: viewModel)
                .tabItem { Label(Strings.Settings.qrBill, systemImage: "qrcode") }

            DownloadsSettings(viewModel: viewModel)
                .tabItem { Label(Strings.Settings.downloads, systemImage: "folder") }

            if FeatureFlags.clientOverrides {
                ClientOverridesSettings()
                    .tabItem { Label(Strings.Settings.clients, systemImage: "person.2") }
            }

            if FeatureFlags.customPDFTemplates {
                TemplatesSettings(viewModel: viewModel)
                    .tabItem { Label(Strings.Settings.templates, systemImage: "doc.richtext") }
            }

            FeedbackSettings()
                .tabItem { Label(Strings.Settings.feedback, systemImage: "bubble.left.and.text.bubble.right") }
        }
        .frame(minWidth: 500, minHeight: 550)
        .task {
            await viewModel.loadSettings()
        }
        .onChange(of: viewModel.harvestCredentials) { viewModel.autoSave() }
        .onChange(of: viewModel.creditorInfo) { viewModel.autoSave() }
        .onChange(of: viewModel.appSettings) { viewModel.autoSave() }
        .onDisappear { viewModel.saveImmediately() }
    }
}

// MARK: - Harvest Settings

struct HarvestSettings: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section(Strings.Settings.apiCredentials) {
                LabeledContent(Strings.Settings.accessToken) {
                    SecureField("", text: $viewModel.harvestCredentials.accessToken)
                        .textContentType(.password)
                        .multilineTextAlignment(.trailing)
                }

                LabeledContent(Strings.Settings.accountID) {
                    TextField("", text: $viewModel.harvestCredentials.accountId)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section {
                HStack {
                    Button(Strings.Settings.testConnection) {
                        Task {
                            await viewModel.testConnection()
                        }
                    }
                    .disabled(viewModel.isTestingConnection || !viewModel.harvestCredentials.canTestConnection)

                    if viewModel.isTestingConnection {
                        ProgressView()
                            .scaleEffect(0.7)
                    }

                    if let result = viewModel.connectionTestResult {
                        switch result {
                        case .success:
                            Label(Strings.Settings.connected, systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        case .failure(let message):
                            Label(Strings.Settings.failed, systemImage: "xmark.circle.fill")
                                .foregroundStyle(.red)
                                .help(message)
                        }
                    }
                }

                if !viewModel.harvestCredentials.subdomain.isEmpty {
                    LabeledContent(Strings.Settings.subdomain) {
                        Text(viewModel.harvestCredentials.subdomain)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Text(Strings.Settings.apiCredentialsHint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - QR Bill Settings

struct QRBillSettings: View {
    @Bindable var viewModel: SettingsViewModel

    private enum Field: Int, CaseIterable {
        case iban, name, street, number, zip, city, country
    }

    @FocusState private var focusedField: Field?

    private func advanceFocus(_ press: KeyPress) -> KeyPress.Result {
        guard let current = focusedField else { return .ignored }
        let offset = press.modifiers.contains(.shift) ? -1 : 1
        guard let next = Field(rawValue: current.rawValue + offset) else { return .ignored }
        focusedField = next
        return .handled
    }

    var body: some View {
        Form {
            Section(Strings.Settings.creditorInformation) {
                LabeledContent(Strings.Settings.iban) {
                    TextField("", text: $viewModel.creditorInfo.iban)
                        .textContentType(.creditCardNumber)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .iban)
                }
                .tapToFocus { focusedField = .iban }

                LabeledContent(Strings.Settings.name) {
                    TextField("", text: $viewModel.creditorInfo.name)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .name)
                }
                .tapToFocus { focusedField = .name }
            }

            Section(Strings.Settings.address) {
                LabeledContent(Strings.Settings.street) {
                    TextField("", text: $viewModel.creditorInfo.streetName)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .street)
                }
                .tapToFocus { focusedField = .street }

                LabeledContent(Strings.Settings.number) {
                    TextField("", text: $viewModel.creditorInfo.buildingNumber)
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .number)
                }
                .tapToFocus { focusedField = .number }

                LabeledContent(Strings.Settings.zip) {
                    TextField("", text: $viewModel.creditorInfo.postalCode)
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .zip)
                }
                .tapToFocus { focusedField = .zip }

                LabeledContent(Strings.Settings.city) {
                    TextField("", text: $viewModel.creditorInfo.town)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .city)
                }
                .tapToFocus { focusedField = .city }

                LabeledContent(Strings.Settings.country) {
                    TextField("", text: $viewModel.creditorInfo.country)
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .country)
                }
                .tapToFocus { focusedField = .country }
            }

            Section {
                Text(Strings.Settings.creditorHint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .onKeyPress(keys: [.tab], action: advanceFocus)
    }
}

// MARK: - Downloads Settings

struct DownloadsSettings: View {
    @Bindable var viewModel: SettingsViewModel

    private var emailSubjectPreview: String {
        viewModel.appSettings.generateEmailSubject(
            invoiceLabel: viewModel.appSettings.templateLanguage.labels["invoice"]!,
            invoiceNumber: "2024-001",
            title: "Web Development",
            clientName: "Example Client",
            creditorName: viewModel.creditorInfo.name.isEmpty ? "Company" : viewModel.creditorInfo.name
        )
    }

    private var filenamePreview: String {
        viewModel.appSettings.generateFilename(
            invoiceNumber: "2024-001",
            creditorName: viewModel.creditorInfo.name.isEmpty ? "Company" : viewModel.creditorInfo.name,
            clientName: "Example Client",
            date: Date(),
            issueDate: Date(),
            dueDate: Date(),
            paidDate: Date()
        )
    }

    var body: some View {
        Form {
            Section(Strings.Settings.saveLocation) {
                Picker(Strings.Settings.saveBehavior, selection: $viewModel.appSettings.downloadBehavior) {
                    ForEach(DownloadBehavior.allCases, id: \.self) { behavior in
                        Text(behavior.displayName).tag(behavior)
                    }
                }
                .pickerStyle(.radioGroup)

                if viewModel.appSettings.downloadBehavior == .useDefaultFolder {
                    LabeledContent(Strings.Settings.folder) {
                        HStack {
                            Text(viewModel.appSettings.defaultDownloadPath ?? Strings.Settings.notSet)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Button(Strings.Settings.chooseFolder) {
                                viewModel.selectDownloadFolder()
                            }
                        }
                    }
                }
            }

            Section(Strings.Settings.filename) {
                LabeledContent(Strings.Settings.pattern) {
                    TextField("", text: $viewModel.appSettings.filenamePattern)
                        .font(.system(.body, design: .monospaced))
                        .multilineTextAlignment(.trailing)
                }

                LabeledContent(Strings.Settings.dateFormat) {
                    TextField("", text: $viewModel.appSettings.dateFormat)
                        .font(.system(.body, design: .monospaced))
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }

                LabeledContent(Strings.Common.preview) {
                    Text(filenamePreview)
                        .foregroundStyle(.secondary)
                        .font(.system(.body, design: .monospaced))
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Strings.Settings.availablePlaceholders)
                        .fontWeight(.medium)
                    Text(Strings.Settings.placeholderNumber)
                    Text(Strings.Settings.placeholderCreditor)
                    Text(Strings.Settings.placeholderClient)
                    Text(Strings.Settings.placeholderDate)
                    Text(Strings.Settings.placeholderIssueDate)
                    Text(Strings.Settings.placeholderDueDate)
                    Text(Strings.Settings.placeholderPaidDate)

                    Text(Strings.Settings.dateFormatComponents)
                        .fontWeight(.medium)
                        .padding(.top, 4)
                    Text(Strings.Settings.dateFormatHelp)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
            }

            Section(Strings.Settings.emailSubject) {
                LabeledContent(Strings.Settings.pattern) {
                    TextField("", text: $viewModel.appSettings.emailSubjectPattern)
                        .font(.system(.body, design: .monospaced))
                        .multilineTextAlignment(.trailing)
                }

                LabeledContent(Strings.Common.preview) {
                    Text(emailSubjectPreview)
                        .foregroundStyle(.secondary)
                        .font(.system(.body, design: .monospaced))
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Strings.Settings.availablePlaceholders)
                        .fontWeight(.medium)
                    Text(Strings.Settings.emailPlaceholderInvoice)
                    Text(Strings.Settings.emailPlaceholderNumber)
                    Text(Strings.Settings.emailPlaceholderTitle)
                    Text(Strings.Settings.emailPlaceholderClient)
                    Text(Strings.Settings.emailPlaceholderCreditor)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
            }

            PaidMarkSettings(viewModel: viewModel)

            #if DEBUG
            Section(Strings.Settings.demo) {
                Toggle(Strings.Settings.demoMode, isOn: $viewModel.appSettings.isDemoMode)
            }
            #endif
        }
        .formStyle(.grouped)
    }
}

// MARK: - Paid Mark Settings

struct PaidMarkSettings: View {
    @Bindable var viewModel: SettingsViewModel
    @State private var isStyleExpanded = false

    var body: some View {
        Section(Strings.Settings.paidMark) {
            Toggle(Strings.Settings.showWatermark, isOn: $viewModel.appSettings.paidMarkStyle.enabled)

            if viewModel.appSettings.paidMarkStyle.enabled {
                Toggle(Strings.Settings.showPaidDate, isOn: $viewModel.appSettings.paidMarkStyle.showDate)

                DisclosureGroup(Strings.Settings.watermarkStyle, isExpanded: $isStyleExpanded) {
                    TextEditor(text: $viewModel.appSettings.paidMarkStyle.css)
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 160)
                        .scrollContentBackground(.hidden)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.background)
                                .shadow(color: .black.opacity(0.05), radius: 1)
                        )

                    HStack {
                        Text(Strings.Settings.watermarkHtmlHint)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button(Strings.Settings.resetToDefault) {
                            viewModel.appSettings.paidMarkStyle.css = PaidMarkStyle.defaultCSS
                        }
                        .controlSize(.small)
                        .disabled(viewModel.appSettings.paidMarkStyle.css == PaidMarkStyle.defaultCSS)
                    }
                }
            }
        }
    }
}

// MARK: - Templates Settings

struct TemplatesSettings: View {
    @Bindable var viewModel: SettingsViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showLabelEditor = false

    var body: some View {
        ScrollView {
            Form {
                Section(Strings.Settings.companyLogo) {
                    HStack {
                        if let logo = viewModel.logoImage {
                            Image(nsImage: logo)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 48)
                        } else {
                            Text(Strings.Settings.noLogoSet)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        HStack(spacing: 6) {
                            Button(Strings.Settings.chooseImage) {
                                viewModel.selectLogo()
                            }

                            if viewModel.logoImage != nil {
                                Button(Strings.Settings.remove, role: .destructive) {
                                    viewModel.removeLogo()
                                }
                            }
                        }
                    }
                    Text(Strings.Settings.logoHint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section(Strings.Settings.invoicePDFSource) {
                    Picker(Strings.Settings.pdfSource, selection: $viewModel.appSettings.pdfSource) {
                        ForEach(InvoicePDFSource.allCases, id: \.self) { source in
                            Text(source.displayName).tag(source)
                        }
                    }
                    .pickerStyle(.radioGroup)

                    HStack {
                        Picker(Strings.Settings.language, selection: $viewModel.appSettings.templateLanguage) {
                            ForEach(TemplateLanguage.allCases, id: \.self) { lang in
                                Text(lang.displayName).tag(lang)
                            }
                        }

                        Button {
                            showLabelEditor = true
                        } label: {
                            Image(systemName: "character.textbox")
                        }
                        .help(Strings.Settings.customizeLabels)
                    }

                    if viewModel.appSettings.pdfSource == .template {
                        Toggle(Strings.Settings.showQuantityColumn, isOn: $viewModel.appSettings.columnVisibility.showQuantity)
                        Toggle(Strings.Settings.showUnitPriceColumn, isOn: $viewModel.appSettings.columnVisibility.showUnitPrice)
                        Toggle(Strings.Settings.showTotalHours, isOn: $viewModel.appSettings.columnVisibility.showTotalHours)
                    } else {
                        Text(Strings.Settings.harvestColumnHint)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                }
            }
            .sheet(isPresented: $showLabelEditor) {
                LabelEditorSheet(
                    labelOverrides: $viewModel.appSettings.labelOverrides,
                    initialLanguage: viewModel.appSettings.templateLanguage
                )
            }
            .formStyle(.grouped)
            .frame(maxHeight: .infinity, alignment: .top)
            .fixedSize(horizontal: false, vertical: true)

            TemplateListView(
                activeTemplateId: viewModel.appSettings.pdfSource == .template
                    ? $viewModel.appSettings.selectedTemplateId : nil,
                language: viewModel.appSettings.templateLanguage,
                labelOverrides: viewModel.appSettings.labelOverrides,
                columnVisibility: viewModel.appSettings.columnVisibility
            )
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .scrollBounceBehavior(.basedOnSize)
        .onChange(of: viewModel.appSettings.pdfSource) {
            guard viewModel.appSettings.pdfSource == .template,
                  viewModel.appSettings.selectedTemplateId == nil else { return }

            let descriptor = FetchDescriptor<InvoiceTemplate>(
                sortBy: [SortDescriptor(\.name)]
            )
            if let first = try? modelContext.fetch(descriptor).first {
                viewModel.appSettings.selectedTemplateId = first.id
            }
        }
    }
}

// MARK: - Feedback Settings

struct FeedbackSettings: View {
    var body: some View {
        Form {
            Section(Strings.Settings.contact) {
                Link(destination: URL(string: "mailto:hello@harvie.app")!) {
                    Label(Strings.Settings.contactEmail, systemImage: "envelope")
                }

                Link(destination: URL(string: "https://harvie.app")!) {
                    Label(Strings.Settings.websiteURL, systemImage: "globe")
                }

                Link(destination: URL(string: "https://harvie.app/privacy-policy")!) {
                    Label(Strings.Settings.privacyPolicy, systemImage: "hand.raised")
                }

                Text(Strings.Settings.contactHint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section(Strings.Settings.reportAnIssue) {
                Link(destination: URL(string: "https://github.com/jorisnoo/Harvie/issues")!) {
                    Label(Strings.Settings.openGitHubIssues, systemImage: "exclamationmark.bubble")
                }

                Text(Strings.Settings.reportHint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - Helpers

private extension View {
    func tapToFocus(_ action: @escaping () -> Void) -> some View {
        contentShape(Rectangle())
            .onTapGesture(perform: action)
    }
}

#Preview {
    SettingsView()
}
