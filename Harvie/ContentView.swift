//
//  ContentView.swift
//  Harvie
//

import SwiftUI
import SwiftData

extension Notification.Name {
    static let refreshInvoices = Notification.Name("RefreshInvoices")
    static let refreshEstimates = Notification.Name("RefreshEstimates")
    static let searchInvoices = Notification.Name("SearchInvoices")
    static let insertTemplateVariable = Notification.Name("InsertTemplateVariable")
}

enum SidebarSelection: Hashable {
    case invoices(InvoiceState?)
    case estimates(EstimateState?)
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var invoicesVM = InvoicesViewModel()
    @State private var estimatesVM = EstimatesViewModel()
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var isSearching = false
    @SceneStorage("documentSource") private var sourceRaw: String = DocumentSource.invoices.rawValue

    private var source: Binding<DocumentSource> {
        Binding(
            get: { DocumentSource(rawValue: sourceRaw) ?? .invoices },
            set: { sourceRaw = $0.rawValue }
        )
    }

    private var estimatesEnabled: Bool { FeatureFlags.estimates }

    private var sidebarSelection: Binding<SidebarSelection> {
        Binding(
            get: {
                switch source.wrappedValue {
                // Invoice state is owned by the chip bar, not the picker.
                case .invoices: .invoices(nil)
                case .estimates: .estimates(estimatesVM.stateFilter)
                }
            },
            set: { new in
                switch new {
                case .invoices:
                    sourceRaw = DocumentSource.invoices.rawValue
                case .estimates(let state):
                    sourceRaw = DocumentSource.estimates.rawValue
                    estimatesVM.stateFilter = state
                }
            }
        )
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
                .navigationSplitViewColumnWidth(min: 300, ideal: 360)
        } detail: {
            detail
        }
        .searchable(text: searchTextBinding, isPresented: $isSearching, placement: .sidebar, prompt: searchPrompt)
        .onReceive(NotificationCenter.default.publisher(for: .searchInvoices)) { _ in
            isSearching = true
        }
        .overlay { ExportOverlayView(invoicesVM: invoicesVM, estimatesVM: estimatesVM, source: source.wrappedValue) }
        .overlay { MoneyRainOverlay() }
        .task {
            invoicesVM.modelContext = modelContext
            await invoicesVM.loadSavedState()
            invoicesVM.loadInvoices()

            if estimatesEnabled {
                estimatesVM.modelContext = modelContext
                await estimatesVM.loadSavedState()
                estimatesVM.loadEstimates()
            }
        }
    }

    @ViewBuilder
    private var sidebar: some View {
        Group {
            switch source.wrappedValue {
            case .invoices:
                InvoicesListView(viewModel: invoicesVM)
            case .estimates:
                EstimatesListView(viewModel: estimatesVM)
            }
        }
        .toolbar {
            if columnVisibility != .detailOnly {
                ToolbarItem(placement: .automatic) {
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 8) {
                            if source.wrappedValue == .invoices {
                                sortFilterMenu
                            }
                            if estimatesEnabled {
                                statePicker
                            }
                        }

                        Menu {
                            if source.wrappedValue == .invoices {
                                sortFilterMenuItems
                            }
                            if estimatesEnabled {
                                Picker("Filter", selection: sidebarSelection) {
                                    statePickerContent
                                }
                                .pickerStyle(.inline)
                            }
                        } label: {
                            Label(Strings.Common.more, systemImage: "ellipsis.circle")
                        }
                    }
                }
            }
        }
    }

    private var sortFilterMenu: some View {
        Menu {
            sortFilterMenuItems
        } label: {
            Label(sortFilterMenuLabel, systemImage: "line.3.horizontal.decrease.circle")
        }
        .focusable(false)
    }

    private var statePicker: some View {
        Picker("Filter", selection: sidebarSelection) {
            statePickerContent
        }
        .pickerStyle(.menu)
    }

    private var sortFilterMenuLabel: String {
        if let period = invoicesVM.selectedPeriod {
            return invoicesVM.formatPeriod(period)
        }
        return Strings.InvoicesList.sortAndFilter
    }

    @ViewBuilder
    private var sortFilterMenuItems: some View {
        Section(Strings.InvoicesList.sortBy) {
            ForEach(InvoiceSortOption.allCases, id: \.self) { option in
                Button {
                    if invoicesVM.sortOption == option {
                        invoicesVM.sortDirection.toggle()
                    } else {
                        invoicesVM.sortOption = option
                        invoicesVM.sortDirection = .descending
                    }
                } label: {
                    HStack {
                        Text(option.rawValue)
                        if invoicesVM.sortOption == option {
                            Image(systemName: invoicesVM.sortDirection == .ascending ? "chevron.up" : "chevron.down")
                        }
                    }
                }
                .disabled(!invoicesVM.validSortOptions.contains(option))
            }
        }

        Section(Strings.InvoicesList.filterPeriod) {
            ForEach(DateFilterPeriod.allCases, id: \.self) { period in
                Button {
                    if invoicesVM.filterPeriod != period {
                        invoicesVM.filterPeriod = period
                        invoicesVM.selectedPeriod = nil
                    }
                } label: {
                    HStack {
                        Text(period.rawValue)
                        if invoicesVM.filterPeriod == period {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }

        Section(Strings.InvoicesList.filterByPeriod(invoicesVM.filterPeriod.rawValue)) {
            Button {
                invoicesVM.selectedPeriod = nil
            } label: {
                HStack {
                    Text(Strings.InvoicesList.all)
                    if invoicesVM.selectedPeriod == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }

            ForEach(invoicesVM.availablePeriods, id: \.self) { period in
                Button {
                    invoicesVM.selectedPeriod = period
                } label: {
                    HStack {
                        Text(invoicesVM.formatPeriod(period))
                        if let selected = invoicesVM.selectedPeriod, selected == period {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var statePickerContent: some View {
        // The picker only switches the document source; invoice state lives in the chip bar.
        Text(Strings.DocumentSource.invoices).tag(SidebarSelection.invoices(nil))
        Section(Strings.DocumentSource.estimates) {
            Text(Strings.EstimatesList.stateSent).tag(SidebarSelection.estimates(.sent))
            Text(Strings.EstimatesList.stateAccepted).tag(SidebarSelection.estimates(.accepted))
            Text(Strings.EstimatesList.stateDraft).tag(SidebarSelection.estimates(.draft))
            Text(Strings.EstimatesList.stateDeclined).tag(SidebarSelection.estimates(.declined))
            Text(Strings.EstimatesList.all).tag(SidebarSelection.estimates(nil))
        }
    }

    @ViewBuilder
    private var detail: some View {
        switch source.wrappedValue {
        case .invoices:
            InvoicesDetailContentView(viewModel: invoicesVM)
        case .estimates:
            EstimatesDetailContentView(viewModel: estimatesVM)
        }
    }

    private var searchTextBinding: Binding<String> {
        switch source.wrappedValue {
        case .invoices:
            return Binding(get: { invoicesVM.searchText }, set: { invoicesVM.searchText = $0 })
        case .estimates:
            return Binding(get: { estimatesVM.searchText }, set: { estimatesVM.searchText = $0 })
        }
    }

    private var searchPrompt: String {
        switch source.wrappedValue {
        case .invoices: Strings.InvoicesList.filterPrompt
        case .estimates: Strings.EstimatesList.filterPrompt
        }
    }
}

private struct ExportOverlayView: View {
    var invoicesVM: InvoicesViewModel
    var estimatesVM: EstimatesViewModel
    var source: DocumentSource

    var body: some View {
        switch source {
        case .invoices:
            if invoicesVM.isExporting {
                ExportProgressOverlay(
                    progress: invoicesVM.exportProgress,
                    message: invoicesVM.exportProgressMessage
                )
            }
        case .estimates:
            if estimatesVM.isExporting {
                EstimateExportProgressOverlay(
                    progress: estimatesVM.exportProgress,
                    message: estimatesVM.exportProgressMessage
                )
            }
        }
    }
}

private struct InvoicesDetailContentView: View {
    @Bindable var viewModel: InvoicesViewModel

    var body: some View {
        if viewModel.selectedInvoiceIDs.count > 1 {
            MultiSelectionView(viewModel: viewModel)
        } else if let invoice = viewModel.selectedInvoice {
            InvoiceDetailView(
                invoice: invoice,
                creditorInfo: viewModel.creditorInfo,
                appSettings: viewModel.appSettings,
                onRefresh: { viewModel.refreshInvoices(ids: [invoice.id]) },
                onStateChanged: { id, newState in
                    if newState == .paid {
                        viewModel.refreshCurrentFilter()
                    } else {
                        viewModel.switchFilterAndSelect(invoiceId: id, to: newState)
                    }
                }
            )
            .id(invoice.id)
        } else {
            ContentUnavailableView(
                Strings.InvoiceDetail.selectAnInvoice,
                systemImage: "doc.text",
                description: Text(Strings.InvoiceDetail.selectAnInvoiceDescription)
            )
        }
    }
}

private struct EstimatesDetailContentView: View {
    @Bindable var viewModel: EstimatesViewModel

    var body: some View {
        if let estimate = viewModel.selectedEstimate {
            EstimateDetailView(
                estimate: estimate,
                creditorInfo: viewModel.creditorInfo,
                appSettings: viewModel.appSettings,
                onRefresh: { viewModel.refreshEstimates(ids: [estimate.id]) },
                onStateChanged: { id, newState in
                    viewModel.switchFilterAndSelect(estimateId: id, to: newState)
                }
            )
            .id(estimate.id)
        } else {
            ContentUnavailableView(
                Strings.EstimateDetail.selectAnEstimate,
                systemImage: "doc.richtext",
                description: Text(Strings.EstimateDetail.selectAnEstimateDescription)
            )
        }
    }
}

#Preview {
    ContentView()
}
