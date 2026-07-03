//
//  InvoicesListView.swift
//  Harvie
//

import SwiftUI

struct InvoicesListView: View {
    @Bindable var viewModel: InvoicesViewModel
    @Environment(\.openSettings) private var openSettings

    private var warningBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(Strings.InvoicesList.creditorWarning)
                .font(.callout)
                .lineLimit(1)
            Spacer()
            Button(Strings.Common.settings) {
                openSettings()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.orange.opacity(0.1))
    }

    @ViewBuilder
    private var invoicesList: some View {
        VStack(spacing: 0) {
            InvoiceStateFilterBar(viewModel: viewModel)

            if !viewModel.canExportWithQRBill {
                warningBanner
            }

            ScrollViewReader { proxy in
                List(selection: $viewModel.selectedInvoiceIDs) {
                    ForEach(viewModel.sortedInvoices) { invoice in
                        InvoiceRowView(
                            invoice: invoice,
                            sortOption: viewModel.sortOption
                        )
                        .tag(invoice.id)
                        // TODO: Re-enable drag-and-drop export once fully working
                        // .onDrag { viewModel.createDragProvider(for: invoice) }
                    }
                }
                .onKeyPress(.escape) {
                    guard !viewModel.selectedInvoiceIDs.isEmpty else { return .ignored }
                    viewModel.selectedInvoiceIDs.removeAll()
                    return .handled
                }
                .contextMenu(forSelectionType: Int.self) { selectedIDs in
                    if !selectedIDs.isEmpty {
                        if viewModel.allSelectedAreDrafts {
                            Button {
                                viewModel.initiateMarkAsSent()
                            } label: {
                                Label(Strings.InvoiceDetail.markAsSent, systemImage: "paperplane")
                            }
                            .disabled(viewModel.isUpdating)
                        }

                        if viewModel.allSelectedAreOpen {
                            Button {
                                viewModel.initiateMarkAsPaid()
                            } label: {
                                Label(Strings.InvoiceDetail.markAsPaid, systemImage: "banknote")
                            }
                            .disabled(viewModel.isUpdating)

                            Button {
                                viewModel.showMarkAsDraftSheet = true
                            } label: {
                                Label(Strings.InvoiceDetail.markAsDraft, systemImage: "arrow.uturn.backward")
                            }
                            .disabled(viewModel.isUpdating)
                        }

                        if viewModel.allSelectedArePaid {
                            Button {
                                viewModel.showMarkAsOpenSheet = true
                            } label: {
                                Label(Strings.InvoiceDetail.markAsOpen, systemImage: "arrow.uturn.backward")
                            }
                            .disabled(viewModel.isUpdating)
                        }

                        if viewModel.allSelectedAreDrafts || viewModel.allSelectedAreOpen {
                            Button {
                                viewModel.initiateChangeDate()
                            } label: {
                                Label(Strings.InvoiceDetail.changeDate, systemImage: "calendar")
                            }
                            .disabled(viewModel.isUpdating)
                        }

                        Divider()

                        Button {
                            Task {
                                await viewModel.exportSelectedInvoices(withQRBill: true)
                            }
                        } label: {
                            Label(Strings.InvoicesList.exportWithQRBill, systemImage: "square.and.arrow.down")
                        }
                        .disabled(!viewModel.canExportWithQRBill)

                        Button {
                            Task {
                                await viewModel.exportSelectedInvoices(withQRBill: false)
                            }
                        } label: {
                            Label(Strings.InvoicesList.exportWithoutQRBill, systemImage: "doc.text")
                        }
                    }
                } primaryAction: { selectedIDs in
                    if let firstID = selectedIDs.first {
                        viewModel.selectedInvoiceIDs = [firstID]
                    }
                }
                .onChange(of: viewModel.selectedStates) {
                    guard let firstInvoiceID = viewModel.sortedInvoices.first?.id else { return }
                    proxy.scrollTo(firstInvoiceID, anchor: .top)
                }
            }

            SidebarStatusBar(invoices: viewModel.sortedInvoices)
        }
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.invoices.isEmpty {
                ProgressView(Strings.InvoicesList.loading)
            } else if let error = viewModel.error {
                if !viewModel.hasValidCredentials {
                    ContentUnavailableView {
                        Label(Strings.InvoicesList.setupRequired, systemImage: "gear")
                    } description: {
                        Text(error)
                    } actions: {
                        Button(Strings.InvoicesList.openSettings) {
                            openSettings()
                        }
                        .buttonStyle(.borderedProminent)

                        Button(Strings.Common.retry) {
                            viewModel.loadInvoices()
                        }
                    }
                } else {
                    ContentUnavailableView {
                        Label(Strings.Common.error, systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    } actions: {
                        Button(Strings.Common.retry) {
                            viewModel.loadInvoices()
                        }
                    }
                }
            } else if viewModel.invoices.isEmpty {
                ContentUnavailableView {
                    Label(Strings.InvoicesList.noInvoices, systemImage: "doc.text")
                } description: {
                    Text(Strings.InvoicesList.noInvoicesDescription)
                } actions: {
                    Button(Strings.Common.refresh) {
                        viewModel.refresh()
                    }
                }
            } else {
                invoicesList
            }
        }
        .navigationTitle(Strings.InvoicesList.title)
        .navigationSubtitle(viewModel.isRefreshing ? Strings.InvoicesList.updating : "")
        .modifier(InvoicesAlertsModifier(viewModel: viewModel))
        .modifier(InvoicesOnChangeModifier(viewModel: viewModel))
        .modifier(InvoicesActionSheetsModifier(viewModel: viewModel))
    }
}

// MARK: - Batch action sheets (shared by context menu and multi-selection view)

struct InvoicesActionSheetsModifier: ViewModifier {
    @Bindable var viewModel: InvoicesViewModel

    private var selectionCount: Int { viewModel.selectedInvoices.count }

    private var batchProgressView: some View {
        VStack(spacing: 6) {
            ProgressView(
                value: Double(viewModel.updatedCount),
                total: Double(viewModel.updateTotalCount)
            )
            Text("\(viewModel.updatedCount) of \(viewModel.updateTotalCount)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $viewModel.showChangeDateSheet) {
                ConfirmationSheet(
                    title: Strings.InvoiceDetail.changeIssueDate,
                    message: Strings.MultiSelection.setIssueDateMessage(selectionCount),
                    confirmLabel: Strings.Common.apply,
                    isProcessing: viewModel.isUpdating,
                    onConfirm: {
                        Task {
                            await viewModel.updateIssueDateForSelected(to: viewModel.batchIssueDate)
                            if viewModel.showUpdateSuccess { viewModel.showChangeDateSheet = false }
                        }
                    },
                    onCancel: { viewModel.showChangeDateSheet = false },
                    width: 300
                ) {
                    HStack {
                        Spacer()
                        Button(Strings.Common.today) { viewModel.batchIssueDate = Date() }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .disabled(Calendar.current.isDateInToday(viewModel.batchIssueDate))
                    }

                    DatePicker(Strings.InvoiceDetail.issueDate, selection: $viewModel.batchIssueDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()

                    if viewModel.isUpdating { batchProgressView }
                }
            }
            .sheet(isPresented: $viewModel.showMarkAsSentSheet) {
                ConfirmationSheet(
                    title: Strings.InvoiceDetail.markAsSent,
                    message: Strings.MultiSelection.markAsSentMessage(selectionCount),
                    detail: Strings.MultiSelection.sentDateDetail,
                    confirmLabel: Strings.InvoiceDetail.markAsSent,
                    isProcessing: viewModel.isUpdating,
                    onConfirm: {
                        Task {
                            await viewModel.markSelectedAsSent()
                            if viewModel.showUpdateSuccess { viewModel.showMarkAsSentSheet = false }
                        }
                    },
                    onCancel: { viewModel.showMarkAsSentSheet = false },
                    width: 300
                ) {
                    if viewModel.isUpdating { batchProgressView }
                }
            }
            .sheet(isPresented: $viewModel.showMarkAsDraftSheet) {
                ConfirmationSheet(
                    title: Strings.InvoiceDetail.markAsDraft,
                    message: Strings.MultiSelection.markAsDraftMessage(selectionCount),
                    confirmLabel: Strings.InvoiceDetail.markAsDraft,
                    isProcessing: viewModel.isUpdating,
                    onConfirm: {
                        Task {
                            await viewModel.markSelectedAsDraft()
                            if viewModel.showUpdateSuccess { viewModel.showMarkAsDraftSheet = false }
                        }
                    },
                    onCancel: { viewModel.showMarkAsDraftSheet = false }
                ) {
                    if viewModel.isUpdating { batchProgressView }
                }
            }
            .sheet(isPresented: $viewModel.showMarkAsPaidSheet) {
                ConfirmationSheet(
                    title: Strings.InvoiceDetail.markAsPaid,
                    message: Strings.MultiSelection.markAsPaidMessage(selectionCount),
                    confirmLabel: Strings.InvoiceDetail.markAsPaid,
                    isProcessing: viewModel.isUpdating,
                    onConfirm: {
                        Task {
                            await viewModel.markSelectedAsPaid(paidAt: viewModel.batchPaymentDate)
                            if viewModel.showUpdateSuccess { viewModel.showMarkAsPaidSheet = false }
                        }
                    },
                    onCancel: { viewModel.showMarkAsPaidSheet = false },
                    width: 300
                ) {
                    HStack {
                        Spacer()
                        Button(Strings.Common.today) { viewModel.batchPaymentDate = Date() }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .disabled(Calendar.current.isDateInToday(viewModel.batchPaymentDate))
                    }
                    DatePicker(Strings.InvoiceDetail.paymentDate, selection: $viewModel.batchPaymentDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                    if viewModel.isUpdating { batchProgressView }
                }
            }
            .sheet(isPresented: $viewModel.showMarkAsOpenSheet) {
                ConfirmationSheet(
                    title: Strings.InvoiceDetail.markAsOpen,
                    message: Strings.MultiSelection.markAsOpenMessage(selectionCount),
                    detail: Strings.InvoiceDetail.reopenDetail,
                    confirmLabel: Strings.InvoiceDetail.markAsOpen,
                    isProcessing: viewModel.isUpdating,
                    onConfirm: {
                        Task {
                            await viewModel.markSelectedAsOpen()
                            if viewModel.showUpdateSuccess { viewModel.showMarkAsOpenSheet = false }
                        }
                    },
                    onCancel: { viewModel.showMarkAsOpenSheet = false }
                ) {
                    if viewModel.isUpdating { batchProgressView }
                }
            }
            .sheet(isPresented: $viewModel.showConfirmDateSheet) {
                ConfirmationSheet(
                    title: Strings.InvoiceDetail.updateIssueDateTitle,
                    message: Strings.MultiSelection.updateIssueDateMessage(selectionCount),
                    detail: Strings.InvoiceDetail.keepCurrentDate,
                    confirmLabel: Strings.InvoiceDetail.setToToday,
                    isProcessing: viewModel.isUpdating,
                    onConfirm: {
                        Task {
                            await viewModel.updateIssueDateForSelected(to: Date())
                            if viewModel.showUpdateSuccess {
                                viewModel.showConfirmDateSheet = false
                                viewModel.showMarkAsSentSheet = true
                            }
                        }
                    },
                    onCancel: {
                        viewModel.showConfirmDateSheet = false
                        viewModel.showMarkAsSentSheet = true
                    }
                ) {
                    if viewModel.isUpdating { batchProgressView }
                }
            }
    }
}

// MARK: - Alerts (isolated observation scope)

private struct InvoicesAlertsModifier: ViewModifier {
    @Bindable var viewModel: InvoicesViewModel

    func body(content: Content) -> some View {
        content
            .alert(Strings.Alerts.exportError, isPresented: .init(
                get: { viewModel.exportError != nil },
                set: { if !$0 { viewModel.exportError = nil } }
            )) {
                Button(Strings.Common.ok) { viewModel.exportError = nil }
            } message: {
                Text(viewModel.exportError ?? "")
            }
            .alert(Strings.Alerts.exportComplete, isPresented: $viewModel.showExportSuccess) {
                Button(Strings.Common.ok) { }
            } message: {
                Text(Strings.Alerts.exportedCount(viewModel.exportedCount))
            }
            .alert(Strings.Alerts.updateError, isPresented: .init(
                get: { viewModel.updateError != nil },
                set: { if !$0 { viewModel.updateError = nil } }
            )) {
                Button(Strings.Common.ok) { viewModel.updateError = nil }
            } message: {
                Text(viewModel.updateError ?? "")
            }
            .alert(Strings.Alerts.updateComplete, isPresented: $viewModel.showUpdateSuccess) {
                Button(Strings.Common.ok) { }
            } message: {
                Text(Strings.Alerts.updatedCount(viewModel.updatedCount))
            }
    }
}

// MARK: - onChange handlers (isolated observation scope)

private struct InvoicesOnChangeModifier: ViewModifier {
    var viewModel: InvoicesViewModel

    func body(content: Content) -> some View {
        content
            .onChange(of: viewModel.sortOption) {
                guard viewModel.isInitialized else { return }
                viewModel.clearInvalidSelections()
                viewModel.debouncedSaveState()
            }
            .onChange(of: viewModel.sortDirection) {
                guard viewModel.isInitialized else { return }
                viewModel.debouncedSaveState()
            }
            .onChange(of: viewModel.filterPeriod) {
                guard viewModel.isInitialized else { return }
                viewModel.clearInvalidSelections()
                viewModel.debouncedSaveState()
            }
            .onChange(of: viewModel.selectedPeriod) {
                guard viewModel.isInitialized else { return }
                viewModel.clearInvalidSelections()
                viewModel.debouncedSaveState()
            }
            .onReceive(NotificationCenter.default.publisher(for: .refreshInvoices)) { _ in
                viewModel.refresh()
            }
            .onReceive(NotificationCenter.default.publisher(for: SettingsViewModel.settingsSavedNotification)) { notification in
                Task { await viewModel.reloadSettings() }
                if notification.userInfo?["needsAPIRefresh"] as? Bool == true {
                    viewModel.loadInvoices()
                }
            }
    }
}

struct ExportProgressOverlay: View {
    let progress: Double
    let message: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView(value: progress) {
                    Text(Strings.InvoicesList.exportingInvoices)
                        .font(.headline)
                } currentValueLabel: {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .progressViewStyle(.linear)
                .frame(width: 250)
            }
            .padding(24)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct SidebarStatusBar: View {
    let invoices: [Invoice]

    private var totalByCurrency: [(currency: String, total: Decimal)] {
        Dictionary(grouping: invoices, by: \.currency)
            .map { (currency: $0.key, total: $0.value.reduce(0) { $0 + $1.displayAmount }) }
            .sorted { $0.currency < $1.currency }
    }

    private var formattedTotal: String {
        totalByCurrency.map { CurrencyFormatter.format($0.total, currency: $0.currency) }.joined(separator: " · ")
    }

    var body: some View {
        if !invoices.isEmpty {
            HStack {
                Text(Strings.InvoicesList.invoiceCount(invoices.count))
                    .contentTransition(.numericText())
                Spacer()
                Text(formattedTotal)
                    .contentTransition(.numericText())
            }
            .animation(.default, value: formattedTotal)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(.bar)
        }
    }
}

struct InvoiceRowView: View {
    let invoice: Invoice
    var sortOption: InvoiceSortOption = .issueDate

    private var formattedAmount: String {
        CurrencyFormatter.format(invoice.displayAmount, currency: invoice.currency)
    }

    private var dateValue: Date {
        switch sortOption {
        case .issueDate: invoice.issueDate
        case .dueDate: invoice.dueDate
        case .paidDate: invoice.effectivePaidDate ?? invoice.issueDate
        }
    }

    private func prefixedDate(_ formatted: String) -> String {
        switch sortOption {
        case .issueDate: Strings.InvoiceDetail.issued(formatted)
        case .dueDate: Strings.InvoiceDetail.due(formatted)
        case .paidDate: Strings.InvoiceDetail.paid(formatted)
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(invoice.number)
                    .font(.headline)

                Text(invoice.client.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                Text(formattedAmount)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .contentTransition(.numericText())
                    .animation(.default, value: invoice.displayAmount)
                    .fixedSize()

                ViewThatFits(in: .horizontal) {
                    Text(prefixedDate(dateValue.formatted(date: .abbreviated, time: .omitted)))
                    Text(prefixedDate(dateValue.formatted(date: .numeric, time: .omitted)))
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StateIndicator: View {
    let state: InvoiceState

    var body: some View {
        Text(state.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(state.color.opacity(0.2))
            .foregroundStyle(state.color)
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        InvoicesListView(viewModel: InvoicesViewModel())
    }
}
