//
//  HarvestCredentials.swift
//  Harvie
//

import Foundation

struct HarvestCredentials: Codable, Sendable, Equatable {
    var accessToken: String
    var accountId: String
    var subdomain: String

    var canTestConnection: Bool {
        !accessToken.isEmpty && !accountId.isEmpty
    }

    var isValid: Bool {
        canTestConnection && !subdomain.isEmpty
    }

    private enum CodingKeys: String, CodingKey {
        case accessToken, accountId, subdomain
    }

    nonisolated init(accessToken: String, accountId: String, subdomain: String) {
        self.accessToken = accessToken
        self.accountId = accountId
        self.subdomain = subdomain
    }

    nonisolated init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decode(String.self, forKey: .accessToken)
        accountId = try container.decode(String.self, forKey: .accountId)
        subdomain = try container.decode(String.self, forKey: .subdomain)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accessToken, forKey: .accessToken)
        try container.encode(accountId, forKey: .accountId)
        try container.encode(subdomain, forKey: .subdomain)
    }
}

struct CreditorInfo: Codable, Sendable, Equatable {
    var iban: String
    var name: String
    var streetName: String
    var buildingNumber: String
    var postalCode: String
    var town: String
    var country: String

    var isValid: Bool {
        !iban.isEmpty && !name.isEmpty && !postalCode.isEmpty && !town.isEmpty && !country.isEmpty
    }

    var structuredAddress: StructuredAddress {
        StructuredAddress(
            name: name,
            streetName: streetName.isEmpty ? nil : streetName,
            buildingNumber: buildingNumber.isEmpty ? nil : buildingNumber,
            postalCode: postalCode,
            town: town,
            country: country
        )
    }

    static var empty: CreditorInfo {
        CreditorInfo(
            iban: "",
            name: "",
            streetName: "",
            buildingNumber: "",
            postalCode: "",
            town: "",
            country: "CH"
        )
    }

    private enum CodingKeys: String, CodingKey {
        case iban, name, streetName, buildingNumber, postalCode, town, country
    }

    nonisolated init(
        iban: String, name: String, streetName: String, buildingNumber: String,
        postalCode: String, town: String, country: String
    ) {
        self.iban = iban
        self.name = name
        self.streetName = streetName
        self.buildingNumber = buildingNumber
        self.postalCode = postalCode
        self.town = town
        self.country = country
    }

    nonisolated init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        iban = try container.decode(String.self, forKey: .iban)
        name = try container.decode(String.self, forKey: .name)
        streetName = try container.decode(String.self, forKey: .streetName)
        buildingNumber = try container.decode(String.self, forKey: .buildingNumber)
        postalCode = try container.decode(String.self, forKey: .postalCode)
        town = try container.decode(String.self, forKey: .town)
        country = try container.decode(String.self, forKey: .country)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(iban, forKey: .iban)
        try container.encode(name, forKey: .name)
        try container.encode(streetName, forKey: .streetName)
        try container.encode(buildingNumber, forKey: .buildingNumber)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encode(town, forKey: .town)
        try container.encode(country, forKey: .country)
    }
}

enum InvoicePDFSource: String, Codable, CaseIterable, Sendable {
    case harvestPDF = "harvest"
    case template = "template"

    var displayName: String {
        switch self {
        case .harvestPDF:
            return "Harvest PDF"
        case .template:
            return "Custom Template"
        }
    }
}

enum DownloadBehavior: String, Codable, CaseIterable, Sendable {
    case askEachTime = "ask"
    case useDefaultFolder = "default"

    var displayName: String {
        switch self {
        case .askEachTime:
            return "Ask each time"
        case .useDefaultFolder:
            return "Save to default folder"
        }
    }
}

struct PaidMarkStyle: Codable, Sendable, Equatable {
    var enabled: Bool
    var showDate: Bool
    var css: String

    nonisolated static let defaultCSS = """
    .watermark {
        position: absolute;
        top: 18mm;
        left: 50%;
        transform: translateX(-50%) rotate(-35deg);
        text-align: center;
        font-family: -apple-system, "Helvetica Neue", Arial, sans-serif;
    }
    .text {
        font-size: 28pt;
        font-weight: 600;
        color: rgb(51, 166, 77);
    }
    .date {
        font-size: 12pt;
        font-weight: 500;
        color: rgb(51, 166, 77);
        margin-top: 2px;
    }
    """

    nonisolated static let `default` = PaidMarkStyle(
        enabled: true, showDate: true, css: defaultCSS
    )
}

struct AppSettings: Codable, Sendable, Equatable {
    var downloadBehavior: DownloadBehavior
    var defaultDownloadPath: String?
    var downloadBookmarkData: Data?
    var filenamePattern: String
    var emailSubjectPattern: String
    var dateFormat: String
    var isDemoMode: Bool

    // PDF source settings
    var pdfSource: InvoicePDFSource
    var selectedTemplateId: UUID?
    var templateLanguage: TemplateLanguage

    // Paid mark watermark
    var paidMarkStyle: PaidMarkStyle

    // Column visibility for custom templates
    var columnVisibility: ColumnVisibility

    // Label customization: [languageRawValue: [labelKey: customValue]]
    // Template keys are bare ("invoice", "subtotal"). QR bill keys prefixed with "qr." ("qr.receipt").
    var labelOverrides: [String: [String: String]]?

    // Persisted filter/sort state
    var lastSortOption: String?
    var lastSortAscending: Bool?
    var lastFilterPeriod: String?
    var lastSelectedPeriod: Date?
    var lastStateFilter: String?
    var lastSelectedStates: [String]?
    var lastSelectedEstimateStates: [String]?

    static let defaultFilenamePattern = "{date}_{number}_{creditor}"
    static let defaultEmailSubjectPattern = "{invoice} {number} {title}"
    static let defaultDateFormat = "YYMMDD"

    static var `default`: AppSettings {
        AppSettings(
            downloadBehavior: .useDefaultFolder,
            defaultDownloadPath: NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true).first,
            downloadBookmarkData: nil,
            filenamePattern: defaultFilenamePattern,
            emailSubjectPattern: defaultEmailSubjectPattern,
            dateFormat: defaultDateFormat,
            isDemoMode: false,
            pdfSource: .harvestPDF,
            selectedTemplateId: nil,
            templateLanguage: .en,
            paidMarkStyle: .default,
            columnVisibility: .default
        )
    }

    // swiftlint:disable:next line_length
    init(downloadBehavior: DownloadBehavior, defaultDownloadPath: String?, downloadBookmarkData: Data?, filenamePattern: String = defaultFilenamePattern, emailSubjectPattern: String = defaultEmailSubjectPattern, dateFormat: String = defaultDateFormat, isDemoMode: Bool = false, pdfSource: InvoicePDFSource = .harvestPDF, selectedTemplateId: UUID? = nil, templateLanguage: TemplateLanguage = .en, paidMarkStyle: PaidMarkStyle = .default, columnVisibility: ColumnVisibility = .default, labelOverrides: [String: [String: String]]? = nil) {
        self.downloadBehavior = downloadBehavior
        self.defaultDownloadPath = defaultDownloadPath
        self.downloadBookmarkData = downloadBookmarkData
        self.filenamePattern = filenamePattern
        self.emailSubjectPattern = emailSubjectPattern
        self.dateFormat = dateFormat
        self.isDemoMode = isDemoMode
        self.pdfSource = pdfSource
        self.selectedTemplateId = selectedTemplateId
        self.templateLanguage = templateLanguage
        self.paidMarkStyle = paidMarkStyle
        self.columnVisibility = columnVisibility
        self.labelOverrides = labelOverrides
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        downloadBehavior = try container.decode(DownloadBehavior.self, forKey: .downloadBehavior)
        defaultDownloadPath = try container.decodeIfPresent(String.self, forKey: .defaultDownloadPath)
        downloadBookmarkData = try container.decodeIfPresent(Data.self, forKey: .downloadBookmarkData)
        filenamePattern = try container.decodeIfPresent(String.self, forKey: .filenamePattern) ?? Self.defaultFilenamePattern
        emailSubjectPattern = try container.decodeIfPresent(String.self, forKey: .emailSubjectPattern) ?? Self.defaultEmailSubjectPattern
        dateFormat = try container.decodeIfPresent(String.self, forKey: .dateFormat) ?? Self.defaultDateFormat
        isDemoMode = try container.decodeIfPresent(Bool.self, forKey: .isDemoMode) ?? false
        pdfSource = try container.decodeIfPresent(InvoicePDFSource.self, forKey: .pdfSource) ?? .harvestPDF
        selectedTemplateId = try container.decodeIfPresent(UUID.self, forKey: .selectedTemplateId)
        templateLanguage = try container.decodeIfPresent(TemplateLanguage.self, forKey: .templateLanguage) ?? .en
        paidMarkStyle = try container.decodeIfPresent(PaidMarkStyle.self, forKey: .paidMarkStyle) ?? .default
        columnVisibility = try container.decodeIfPresent(ColumnVisibility.self, forKey: .columnVisibility) ?? .default
        lastSortOption = try container.decodeIfPresent(String.self, forKey: .lastSortOption)
        lastSortAscending = try container.decodeIfPresent(Bool.self, forKey: .lastSortAscending)
        lastFilterPeriod = try container.decodeIfPresent(String.self, forKey: .lastFilterPeriod)
        lastSelectedPeriod = try container.decodeIfPresent(Date.self, forKey: .lastSelectedPeriod)
        lastStateFilter = try container.decodeIfPresent(String.self, forKey: .lastStateFilter)
        lastSelectedStates = try container.decodeIfPresent([String].self, forKey: .lastSelectedStates)
        lastSelectedEstimateStates = try container.decodeIfPresent([String].self, forKey: .lastSelectedEstimateStates)
        labelOverrides = try container.decodeIfPresent([String: [String: String]].self, forKey: .labelOverrides)
    }

    func resolved(with override: ClientOverride?) -> AppSettings {
        guard let o = override else { return self }
        var s = self
        if let lang = o.templateLanguage { s.templateLanguage = lang }
        if let cv = o.columnVisibility { s.columnVisibility = cv }
        if let lo = o.labelOverrides { s.labelOverrides = lo }
        return s
    }

    var effectivePDFSource: InvoicePDFSource {
        FeatureFlags.customPDFTemplates ? pdfSource : .harvestPDF
    }

    var downloadURL: URL? {
        // Try to resolve from bookmark first (for sandboxed access)
        if let bookmarkData = downloadBookmarkData {
            var isStale = false
            if let url = try? URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            ) {
                return url
            }
        }
        // Fallback to path (works for Downloads folder)
        guard let path = defaultDownloadPath else { return nil }
        return URL(fileURLWithPath: path)
    }

    private static var dateFormatCache: [String: DateFormatter] = [:]

    private func formatDate(_ date: Date) -> String {
        // Convert user format (YYYY, YY, MM, DD) to DateFormatter format (yyyy, yy, MM, dd)
        let format = dateFormat
            .replacingOccurrences(of: "YYYY", with: "yyyy")
            .replacingOccurrences(of: "YY", with: "yy")
            .replacingOccurrences(of: "DD", with: "dd")

        let formatter = Self.dateFormatCache[format] ?? {
            let f = DateFormatter()
            f.dateFormat = format
            Self.dateFormatCache[format] = f
            return f
        }()

        return formatter.string(from: date)
    }

    func generateFilename(
        invoiceNumber: String,
        creditorName: String,
        clientName: String,
        date: Date,
        issueDate: Date,
        dueDate: Date,
        paidDate: Date?
    ) -> String {
        let sanitize: (String) -> String = { input in
            input
                .lowercased()
                .replacingOccurrences(of: " ", with: "_")
                .replacingOccurrences(of: "/", with: "-")
                .filter { $0.isLetter || $0.isNumber || $0 == "_" || $0 == "-" }
        }

        var filename = filenamePattern
        filename = filename.replacingOccurrences(of: "{number}", with: invoiceNumber.replacingOccurrences(of: "/", with: "-"))
        filename = filename.replacingOccurrences(of: "{creditor}", with: sanitize(creditorName))
        filename = filename.replacingOccurrences(of: "{client}", with: sanitize(clientName))
        filename = filename.replacingOccurrences(of: "{date}", with: formatDate(date))
        filename = filename.replacingOccurrences(of: "{issueDate}", with: formatDate(issueDate))
        filename = filename.replacingOccurrences(of: "{dueDate}", with: formatDate(dueDate))
        filename = filename.replacingOccurrences(of: "{paidDate}", with: paidDate.map { formatDate($0) } ?? "")

        return filename + ".pdf"
    }

    func generateEmailSubject(
        invoiceLabel: String,
        invoiceNumber: String,
        title: String?,
        clientName: String,
        creditorName: String
    ) -> String {
        var subject = emailSubjectPattern
        subject = subject.replacingOccurrences(of: "{invoice}", with: invoiceLabel)
        subject = subject.replacingOccurrences(of: "{number}", with: invoiceNumber)
        subject = subject.replacingOccurrences(of: "{title}", with: title ?? "")
        subject = subject.replacingOccurrences(of: "{client}", with: clientName)
        subject = subject.replacingOccurrences(of: "{creditor}", with: creditorName)
        // Collapse multiple spaces from empty placeholders
        return subject.replacingOccurrences(of: "  +", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespaces)
    }
}
