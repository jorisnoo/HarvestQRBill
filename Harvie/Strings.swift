//
//  Strings.swift
//  Harvie
//

import Foundation

enum Strings {

    // MARK: - Common

    enum Common {
        static let ok = "OK"
        static let cancel = "Cancel"
        static let save = "Save"
        static let delete = "Delete"
        static let apply = "Apply"
        static let retry = "Retry"
        static let done = "Done"
        static let today = "Today"
        static let preview = "Preview"
        static let edit = "Edit"
        static let error = "Error"
        static let success = "Success"
        static let select = "Select"
        static let settings = "Settings"
        static let refresh = "Refresh"
        static let find = "Find"
        static let more = "More"
    }

    // MARK: - App

    enum App {
        static let title = "Harvie"
        static let checkForUpdates = "Check for Updates..."
        static let restartAndUpdate = "Restart and Update"
    }

    // MARK: - Invoices List

    enum InvoicesList {
        static let title = "Invoices"
        static let updating = "Updating..."
        static let loading = "Loading invoices..."
        static let noInvoices = "No Invoices"
        static let setupRequired = "Setup Required"
        static let openSettings = "Open Settings"
        static let filterPrompt = "Filter invoices"
        static let exportWithQRBill = "Export with QR Bill"
        static let exportWithoutQRBill = "Export without QR Bill"
        static let sortAndFilter = "Sort & Filter"
        static let sortBy = "Sort By"
        static let filterPeriod = "Filter Period"
        static let all = "All"
        static let stateOpen = "Open"
        static let statePaid = "Paid"
        static let stateDraft = "Draft"
        static let stateClosed = "Closed"
        static let stateFilterHint = "Click to filter by state. Shift-click or \u{2318}-click to select several."
        static let exportingInvoices = "Exporting Invoices"
        static let creditorWarning = "Configure creditor info in Settings to enable QR bill export."

        static func filterByPeriod(_ period: String) -> String {
            "Filter by \(period)"
        }

        static func invoiceCount(_ count: Int) -> String {
            "\(count) invoice\(count == 1 ? "" : "s")"
        }

        static let noInvoicesDescription = "No invoices found."

        static func noInvoicesForState(_ state: String) -> String {
            "No \(state) invoices found."
        }
    }

    // MARK: - Invoice Detail

    enum InvoiceDetail {
        static let previewButton = "Preview"
        static let exportQRBill = "Export QR Bill"
        static let changeDate = "Change Date"
        static let sendViaEmail = "Send via Email\u{2026}"
        static let markAsSentNoEmail = "Mark as Sent (no email)"
        static let send = "Send"
        static let markAsSent = "Mark as Sent"
        static let markAsDraft = "Mark as Draft"
        static let markAsPaid = "Mark as Paid"
        static let markAsOpen = "Mark as Open"
        static let showInFinder = "Show in Finder"
        static let invoiceTitle = "Invoice title"
        static let saveTitle = "Save title"
        static let notes = "Notes"
        static let description = "Description"
        static let price = "Price"
        static let changeIssueDate = "Change Issue Date"
        static let issueDate = "Issue Date"
        static let updateIssueDateTitle = "Update Issue Date?"
        static let setToToday = "Set to Today"
        static let keepCurrentDate = "Press Cancel to keep the current date."

        static func updateIssueDateMessage(_ date: String) -> String {
            "The issue date is set to \(date). Do you want to update it to today?"
        }
        static let invoiceSent = "Invoice Sent"
        static let invoiceReverted = "Invoice Reverted"
        static let invoiceMarkedPaid = "Invoice Paid"
        static let invoiceReopened = "Invoice Reopened"
        static let selectAnInvoice = "Select an Invoice"
        static let selectAnInvoiceDescription = "Choose an invoice from the list to view details and generate a QR bill."

        static let previewTooltip = "Preview invoice PDF with Swiss QR bill (Space)"
        static let exportTooltip = "Download invoice PDF with Swiss QR bill"
        static let creditorRequiredTooltip = "Configure creditor info in Settings first"
        static let sendTooltip = "Send invoice via email or mark as sent"

        static func ofTotal(_ amount: String) -> String {
            "of \(amount) total"
        }

        static func issuedAndSent(_ issueDate: String, _ sentTime: String) -> String {
            "Issued \(issueDate), sent at \(sentTime)"
        }

        static func issued(_ date: String) -> String {
            "Issued \(date)"
        }

        static func sent(_ date: String) -> String {
            "Sent \(date)"
        }

        static func due(_ date: String) -> String {
            "Due \(date)"
        }

        static let dueDate = "Due Date"
        static let uponReceipt = "Upon Receipt"

        static func customDays(_ days: Int) -> String {
            "Custom (\(days) days)"
        }

        static func inclTax(_ rate: String, _ amount: String) -> String {
            "Incl. \(rate)% tax (\(amount))"
        }

        static func discount(_ rate: String, _ amount: String) -> String {
            "Discount \(rate)%: -\(amount)"
        }

        static func paid(_ date: String) -> String {
            "Paid \(date)"
        }

        static func markAsSentMessage(_ number: String) -> String {
            "Mark invoice \(number) as sent?"
        }

        static let sentDateDetail = "The sent date will be set to now."

        static func markAsDraftMessage(_ number: String) -> String {
            "Revert invoice \(number) to draft?"
        }

        static func markAsPaidMessage(_ number: String) -> String {
            "Mark invoice \(number) as paid?"
        }

        static let paymentDate = "Payment Date"
        static let paidDateDetail = "A payment for the full amount will be recorded."

        static func markAsOpenMessage(_ number: String) -> String {
            "Reopen invoice \(number)?"
        }

        static let reopenDetail = "All payment records will be removed."

        static func invoiceSentMessage(_ number: String) -> String {
            "Invoice \(number) has been marked as sent."
        }

        static func invoiceRevertedMessage(_ number: String) -> String {
            "Invoice \(number) has been reverted to draft."
        }

        static func invoiceMarkedPaidMessage(_ number: String) -> String {
            "Invoice \(number) has been marked as paid."
        }

        static func invoiceReopenedMessage(_ number: String) -> String {
            "Invoice \(number) has been reopened."
        }

        static func savedToPath(_ path: String) -> String {
            "Invoice saved to:\n\(path)"
        }

        static let savedSuccessfully = "Invoice with QR bill saved successfully."

        static func failedAction(_ label: String, _ error: String) -> String {
            "Failed to \(label): \(error)"
        }

        static func failedActionGeneric(_ label: String) -> String {
            "Failed to \(label). Please try again."
        }

        static func emailSubject(label: String, number: String, title: String?) -> String {
            if let title, !title.isEmpty {
                return "\(label) \(number) \(title)"
            }
            return "\(label) \(number)"
        }

        static let emailNotConfigured = "Email is not configured on this Mac."
    }

    // MARK: - Estimates List

    enum EstimatesList {
        static let title = "Estimates"
        static let updating = "Updating..."
        static let loading = "Loading estimates..."
        static let noEstimates = "No Estimates"
        static let filterPrompt = "Filter estimates"
        static let export = "Export"
        static let markAsSent = "Mark as Sent"
        static let markAsAccepted = "Mark as Accepted"
        static let markAsDeclined = "Mark as Declined"
        static let reopen = "Reopen"
        static let stateDraft = "Draft"
        static let stateSent = "Sent"
        static let stateAccepted = "Accepted"
        static let stateDeclined = "Declined"
        static let all = "All"
        static let stateFilterHint = "Click to filter by state. Shift-click or \u{2318}-click to select several."
        static let exportingEstimates = "Exporting Estimates"

        static func estimateCount(_ count: Int) -> String {
            "\(count) estimate\(count == 1 ? "" : "s")"
        }

        static func noEstimatesForState(_ state: String) -> String {
            "No \(state) estimates found."
        }

        static let noEstimatesDescription = "No estimates found."
    }

    // MARK: - Estimate Detail

    enum EstimateDetail {
        static let export = "Export"
        static let selectAnEstimate = "Select an Estimate"
        static let selectAnEstimateDescription = "Choose an estimate from the list to view details and export."
        static let notes = "Notes"
        static let exportTooltip = "Download estimate PDF"
        static let markAsSent = "Mark as Sent"
        static let markAsAccepted = "Mark as Accepted"
        static let markAsDeclined = "Mark as Declined"
        static let reopen = "Reopen"
        static let estimateSent = "Estimate Sent"
        static let estimateAccepted = "Estimate Accepted"
        static let estimateDeclined = "Estimate Declined"
        static let estimateReopened = "Estimate Reopened"

        static func estimateSentMessage(_ number: String) -> String {
            "Estimate \(number) has been marked as sent."
        }
        static func estimateAcceptedMessage(_ number: String) -> String {
            "Estimate \(number) has been marked as accepted."
        }
        static func estimateDeclinedMessage(_ number: String) -> String {
            "Estimate \(number) has been marked as declined."
        }
        static func estimateReopenedMessage(_ number: String) -> String {
            "Estimate \(number) has been reopened."
        }
        static func issued(_ date: String) -> String { "Issued \(date)" }
        static func sent(_ date: String) -> String { "Sent \(date)" }
        static func accepted(_ date: String) -> String { "Accepted \(date)" }
        static func declined(_ date: String) -> String { "Declined \(date)" }
    }

    // MARK: - Document Source

    enum DocumentSource {
        static let invoices = "Invoices"
        static let estimates = "Estimates"
    }

    // MARK: - Multi Selection

    enum MultiSelection {
        static let total = "Total"
        static let clients = "Clients"
        static let bullet = "\u{2022}"

        static func invoicesSelected(_ count: Int) -> String {
            "\(count) Invoices Selected"
        }

        static func setIssueDateMessage(_ count: Int) -> String {
            "Set issue date for \(count) invoice(s)"
        }

        static func markAsSentMessage(_ count: Int) -> String {
            "Mark \(count) invoice(s) as sent?"
        }

        static let sentDateDetail = "The sent date will be set to the current time."

        static func updateIssueDateMessage(_ count: Int) -> String {
            "Some of the \(count) selected invoice(s) have an issue date that is not today. Do you want to update them to today?"
        }

        static func markAsDraftMessage(_ count: Int) -> String {
            "Revert \(count) invoice(s) to draft?"
        }

        static func markAsPaidMessage(_ count: Int) -> String {
            "Mark \(count) invoice(s) as paid?"
        }

        static func markAsOpenMessage(_ count: Int) -> String {
            "Reopen \(count) invoice(s)?"
        }
    }

    // MARK: - Settings

    enum Settings {
        static let harvest = "Harvest"
        static let qrBill = "QR Bill"
        static let downloads = "Downloads"
        static let templates = "Templates"
        static let feedback = "Feedback"

        // Harvest
        static let apiCredentials = "API Credentials"
        static let accessToken = "Access Token"
        static let accountID = "Account ID"
        static let testConnection = "Test Connection"
        static let connected = "Connected"
        static let failed = "Failed"
        static let subdomain = "Subdomain"
        static let apiCredentialsHint = "Get your API credentials from Harvest Developer Tools."
        static let getApiKey = "Get an API key"

        // QR Bill
        static let creditorInformation = "Creditor Information"
        static let iban = "IBAN"
        static let name = "Name"
        static let address = "Address"
        static let street = "Street"
        static let number = "Number"
        static let zip = "ZIP"
        static let city = "City"
        static let country = "Country"
        static let creditorHint = "This information appears on the QR bill as the payment recipient."

        // Downloads
        static let saveLocation = "Save Location"
        static let saveBehavior = "Save behavior"
        static let folder = "Folder"
        static let notSet = "Not set"
        static let chooseFolder = "Choose..."
        static let filename = "Filename"
        static let pattern = "Pattern"
        static let dateFormat = "Date format"
        static let availablePlaceholders = "Available placeholders:"
        static let placeholderNumber = "{number} - Invoice number"
        static let placeholderCreditor = "{creditor} - Your company name"
        static let placeholderClient = "{client} - Client name"
        static let placeholderDate = "{date} - Date based on sort"
        static let placeholderIssueDate = "{issueDate} - Issue date"
        static let placeholderDueDate = "{dueDate} - Due date"
        static let placeholderPaidDate = "{paidDate} - Paid date"
        static let dateFormatComponents = "Date format components:"
        static let dateFormatHelp = "YYYY (4-digit year), YY (2-digit year), MM (month), DD (day)"

        // Email Subject
        static let emailSubject = "Email Subject"
        static let emailPlaceholderInvoice = "{invoice} - Localized invoice label"
        static let emailPlaceholderNumber = "{number} - Invoice number"
        static let emailPlaceholderTitle = "{title} - Invoice title"
        static let emailPlaceholderClient = "{client} - Client name"
        static let emailPlaceholderCreditor = "{creditor} - Your company name"

        // Paid Mark
        static let paidMark = "Paid Mark"
        static let showWatermark = "Show watermark on paid invoices"
        static let showPaidDate = "Show paid date"
        static let watermarkStyle = "Watermark Style"
        static let watermarkHtmlHint = "HTML: .watermark > .text + .date"
        static let resetToDefault = "Reset to Default"

        // Company Logo
        static let companyLogo = "Company Logo"
        static let noLogoSet = "No logo set"
        static let chooseImage = "Choose Image..."
        static let remove = "Remove"
        static let logoHint = "Used only in custom templates. Harvest PDFs use the logo configured in Harvest."

        // Templates
        static let invoicePDFSource = "Invoice PDF Source"
        static let pdfSource = "PDF source"
        static let language = "Language"
        static let customizeLabels = "Customize labels"
        static let noCustomLabels = "No labels customized yet."
        static let showQuantityColumn = "Show Quantity column"
        static let showUnitPriceColumn = "Show Unit Price column"
        static let showTotalHours = "Show Total Hours"
        static let templateColumnHint = "To hide columns on Harvest PDFs, change this in the Harvest web UI."
        // swiftlint:disable:next line_length
        static let harvestColumnHint = "Column visibility can be configured when using a custom template. For Harvest PDFs, change this in the Harvest web UI under Invoices \u{2192} Configure \u{2192} Hide columns."

        // Feedback
        static let contact = "Contact"
        static let contactEmail = "hello@harvie.app"
        static let contactHint = "Send us an email with questions, suggestions, or feedback."
        static let website = "Website"
        static let websiteURL = "harvie.app"
        static let privacyPolicy = "Privacy Policy"
        static let reportAnIssue = "Report an Issue"
        static let openGitHubIssues = "Open GitHub Issues"
        static let reportHint = "Report bugs or request features on GitHub."

        // Clients
        static let clients = "Clients"
        static let clientOverrides = "Client Overrides"
        static let addOverride = "Add Override"
        static func overrideCount(_ count: Int) -> String {
            count == 1 ? "1 client" : "\(count) clients"
        }
        static func removeOverride(_ name: String) -> String {
            "Remove Override for \(name)"
        }
        static let overrideLanguage = "Override language"
        static let overrideColumnVisibility = "Override column visibility"
        static let overrideLabels = "Override labels"
        static let noOverridesHint = """
            Add per-client overrides to use different settings for specific clients. \
            Unchecked fields use the global default.
            """
        static let noClientsHint = "Clients will appear here once invoices have been loaded."
        static let selectClient = "Select a client..."

        static func settingsFor(_ name: String) -> String {
            "Settings for \(name)"
        }

        // Debug
        static let demo = "Demo"
        static let demoMode = "Demo Mode"
    }

    // MARK: - Templates

    enum Templates {
        static let templateName = "Template Name"
        static let readOnly = "Read Only"
        static let openInEditor = "Open in Editor"
        static let variables = "Variables"
        static let refreshPreview = "Refresh preview"
        static let newTemplate = "New template"
        static let duplicateTemplate = "Duplicate template"
        static let deleteTemplate = "Delete template"
        static let revealTemplatesFolder = "Reveal templates folder"
        static let deleteTemplateTitle = "Delete Template"
        static let duplicate = "Duplicate"
        static let openInExternalEditor = "Open in External Editor"
        static let revealInFinder = "Reveal in Finder"
        static let untitledTemplate = "Untitled Template"
        static let builtIn = "Built-in"
        static let export = "Export\u{2026}"
        static let exportTemplate = "Export template"
        static let importTemplate = "Import template"
        static let importMessage = "Select a template file to import"
        static let importErrorTitle = "Import Failed"

        static func deleteConfirmation(_ name: String) -> String {
            "Are you sure you want to delete \"\(name)\"? This cannot be undone."
        }

        static func builtInWindowTitle(_ name: String) -> String {
            "\(name) (Built-in \u{2014} Read Only)"
        }

        static func previewWindowTitle(_ name: String) -> String {
            "Preview \u{2014} \(name)"
        }

        static func updatedAt(_ date: String) -> String {
            "Updated \(date)"
        }
    }

    // MARK: - Label Editor

    enum LabelEditor {
        static let title = "Customize Labels"
        static let templateLabels = "Template Labels"
        static let qrBillLabels = "QR Bill Labels"
        static let resetLanguage = "Reset Language"
        static let resetToDefault = "Reset to default"
    }

    // MARK: - Alerts

    enum Alerts {
        static let exportError = "Export Error"
        static let exportComplete = "Export Complete"
        static let updateError = "Update Error"
        static let updateComplete = "Update Complete"

        static func exportedCount(_ count: Int) -> String {
            "Successfully exported \(count) invoice(s)."
        }

        static func updatedCount(_ count: Int) -> String {
            "Successfully updated \(count) invoice(s)."
        }

        static func exportedEstimateCount(_ count: Int) -> String {
            "Successfully exported \(count) estimate(s)."
        }

        static func updatedEstimateCount(_ count: Int) -> String {
            "Successfully updated \(count) estimate(s)."
        }
    }

    // MARK: - Errors

    enum Errors {
        // Credentials
        static let configureCredentials = "Please configure your Harvest API credentials in Settings."
        static let configureCreditor = "Please configure your creditor information in Settings."
        static let noTemplateSelected = "No template selected. Please select a template in Settings > Templates."

        // Connection
        static let fillCredentials = "Please fill in Access Token and Account ID."
        static let connectionFailed = "Connection failed."
        static let connectionFailedNetwork = "Connection failed. Please check your network."

        // API
        static let invalidCredentials = "Invalid API credentials. Please check your settings."
        static let invalidURL = "Failed to construct API request."
        static let invalidSubdomain = "Invalid Harvest subdomain."
        static let unauthorized = "Unauthorized. Please check your API token."
        static let notFound = "Resource not found."
        static let networkFailed = "Network connection failed."
        static let decodingFailed = "Failed to parse server response."

        static func serverError(_ code: Int) -> String {
            "Server error (code: \(code))"
        }

        // PDF
        static let downloadFailed = "Failed to download the PDF from Harvest."
        static let invalidPDF = "The downloaded file is not a valid PDF."
        static let saveFailed = "Failed to save the PDF file."
        static let qrBillGenerationFailed = "Failed to generate the QR bill."
        static let renderingFailed = "Failed to render the template to PDF."
        static let processTerminated = "The web rendering process terminated unexpectedly."
        static let renderingTimeout = "PDF rendering timed out."

        // QR Bill
        static let invalidIBAN = "Invalid IBAN format."
        static let qrIBANNotSupported = "QR-IBAN is not supported. Please use a regular Swiss IBAN."
        static let invalidCreditorAddress = "Creditor address is incomplete."
        static let invalidAmount = "Amount must be between 0.01 and 999,999,999.99."
        static let invalidCurrency = "Currency must be CHF or EUR."
        static let invalidReference = "Invalid creditor reference format."
        static let messageTooLong = "Combined message and billing info must not exceed 140 characters."
    }

    // MARK: - Export

    enum Export {
        static let selectFolderMessage = "Select folder to save invoices"
        static let selectFolderMessageEstimates = "Select folder to save estimates"
        static let exportComplete = "Export complete!"
        static let selectLogoMessage = "Select a company logo image"
        static let choosePrompt = "Choose"
        static let selectFolderForDownloads = "Select default download folder for invoices"

        static func exportingProgress(_ index: Int, _ total: Int, _ number: String) -> String {
            "Exporting \(index) of \(total): \(number)"
        }
    }

    // MARK: - Data Export Window

    enum DataExport {
        static let menuItem = "Export All Data\u{2026}"
        static let windowTitle = "Export Harvest Data"
        static let intro = "Download all data from your Harvest account as JSON and CSV files."
        static let outputFolder = "Output Folder"
        static let chooseFolder = "Choose\u{2026}"
        static let noFolderSelected = "No folder selected"
        static let selectFolderPrompt = "Select a folder to save the exported files"
        static let resourcesSection = "Resources to Export"
        static let formatNote = "Exports both JSON and CSV for each selected resource, plus a manifest.json with run details."
        static let selectAll = "Select All"
        static let selectNone = "Select None"
        static let startExport = "Start Export"
        static let cancel = "Cancel"
        static let exportRunning = "Exporting\u{2026}"
        static let revealInFinder = "Reveal in Finder"
        static let needsCredentials = "Connect your Harvest account in Settings before exporting."

        static func progressMessage(_ resource: String, _ done: Int, _ total: Int) -> String {
            "Exporting \(resource) (\(done) of \(total))\u{2026}"
        }

        static func successSummary(_ resourceCount: Int, _ rowCount: Int) -> String {
            "Exported \(resourceCount) resource\(resourceCount == 1 ? "" : "s") (\(rowCount) total record\(rowCount == 1 ? "" : "s"))."
        }

        static func failureSummary(_ message: String) -> String {
            "Export failed: \(message)"
        }
    }
}
