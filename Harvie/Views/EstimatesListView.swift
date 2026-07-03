//
//  EstimatesListView.swift
//  Harvie
//

import SwiftUI

struct EstimatesListView: View {
    @Bindable var viewModel: EstimatesViewModel
    @Environment(\.openSettings) private var openSettings

    @ViewBuilder
    private var estimatesList: some View {
        VStack(spacing: 0) {
            EstimateStateFilterBar(viewModel: viewModel)

            ScrollViewReader { proxy in
                List(selection: $viewModel.selectedEstimateIDs) {
                    ForEach(viewModel.sortedEstimates) { estimate in
                        EstimateRowView(estimate: estimate)
                            .tag(estimate.id)
                    }
                }
                .onKeyPress(.escape) {
                    guard !viewModel.selectedEstimateIDs.isEmpty else { return .ignored }
                    viewModel.selectedEstimateIDs.removeAll()
                    return .handled
                }
                .contextMenu(forSelectionType: Int.self) { selectedIDs in
                    if !selectedIDs.isEmpty {
                        Button {
                            Task { await viewModel.exportSelectedEstimates() }
                        } label: {
                            Label(Strings.EstimatesList.export, systemImage: "square.and.arrow.down")
                        }

                        Divider()

                        if viewModel.allSelectedAreDrafts {
                            Button {
                                Task { await viewModel.markSelectedAsSent() }
                            } label: {
                                Label(Strings.EstimatesList.markAsSent, systemImage: "paperplane")
                            }
                        }

                        if viewModel.allSelectedAreSent {
                            Button {
                                Task { await viewModel.markSelectedAsAccepted() }
                            } label: {
                                Label(Strings.EstimatesList.markAsAccepted, systemImage: "checkmark.circle")
                            }
                            Button {
                                Task { await viewModel.markSelectedAsDeclined() }
                            } label: {
                                Label(Strings.EstimatesList.markAsDeclined, systemImage: "xmark.circle")
                            }
                        }

                        if viewModel.allSelectedAreFinalized {
                            Button {
                                Task { await viewModel.reopenSelected() }
                            } label: {
                                Label(Strings.EstimatesList.reopen, systemImage: "arrow.uturn.backward")
                            }
                        }
                    }
                } primaryAction: { selectedIDs in
                    if let firstID = selectedIDs.first {
                        viewModel.selectedEstimateIDs = [firstID]
                    }
                }
                .onChange(of: viewModel.selectedStates) {
                    guard let firstEstimateID = viewModel.sortedEstimates.first?.id else { return }
                    proxy.scrollTo(firstEstimateID, anchor: .top)
                }
            }

            EstimatesStatusBar(estimates: viewModel.sortedEstimates)
        }
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.estimates.isEmpty {
                ProgressView(Strings.EstimatesList.loading)
            } else if let error = viewModel.error {
                if !viewModel.hasValidCredentials {
                    ContentUnavailableView {
                        Label(Strings.InvoicesList.setupRequired, systemImage: "gear")
                    } description: {
                        Text(error)
                    } actions: {
                        Button(Strings.InvoicesList.openSettings) { openSettings() }
                            .buttonStyle(.borderedProminent)
                        Button(Strings.Common.retry) { viewModel.loadEstimates() }
                    }
                } else {
                    ContentUnavailableView {
                        Label(Strings.Common.error, systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    } actions: {
                        Button(Strings.Common.retry) { viewModel.loadEstimates() }
                    }
                }
            } else if viewModel.estimates.isEmpty {
                ContentUnavailableView {
                    Label(Strings.EstimatesList.noEstimates, systemImage: "doc.richtext")
                } description: {
                    Text(Strings.EstimatesList.noEstimatesDescription)
                } actions: {
                    Button(Strings.Common.refresh) { viewModel.refresh() }
                }
            } else {
                estimatesList
            }
        }
        .navigationTitle(Strings.EstimatesList.title)
        .navigationSubtitle(viewModel.isRefreshing ? Strings.EstimatesList.updating : "")
        .modifier(EstimatesAlertsModifier(viewModel: viewModel))
        .modifier(EstimatesOnChangeModifier(viewModel: viewModel))
    }
}

// MARK: - Alerts

private struct EstimatesAlertsModifier: ViewModifier {
    @Bindable var viewModel: EstimatesViewModel

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
                Text(Strings.Alerts.exportedEstimateCount(viewModel.exportedCount))
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
                Text(Strings.Alerts.updatedEstimateCount(viewModel.updatedCount))
            }
    }
}

// MARK: - onChange handlers

private struct EstimatesOnChangeModifier: ViewModifier {
    var viewModel: EstimatesViewModel

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .refreshEstimates)) { _ in
                viewModel.refresh()
            }
            .onReceive(NotificationCenter.default.publisher(for: SettingsViewModel.settingsSavedNotification)) { _ in
                Task { await viewModel.reloadSettings() }
            }
    }
}

// MARK: - Status Bar

private struct EstimatesStatusBar: View {
    let estimates: [Estimate]

    private var totalByCurrency: [(currency: String, total: Decimal)] {
        Dictionary(grouping: estimates, by: \.currency)
            .map { (currency: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.currency < $1.currency }
    }

    private var formattedTotal: String {
        totalByCurrency.map { CurrencyFormatter.format($0.total, currency: $0.currency) }.joined(separator: " \u{00B7} ")
    }

    var body: some View {
        if !estimates.isEmpty {
            HStack {
                Text(Strings.EstimatesList.estimateCount(estimates.count))
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

// MARK: - Row

struct EstimateRowView: View {
    let estimate: Estimate

    private var formattedAmount: String {
        CurrencyFormatter.format(estimate.amount, currency: estimate.currency)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(estimate.number)
                    .font(.headline)
                    .lineLimit(1)
                Text(estimate.client.name)
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
                    .animation(.default, value: estimate.amount)
                    .fixedSize()

                ViewThatFits(in: .horizontal) {
                    Text(Strings.EstimateDetail.issued(estimate.issueDate.formatted(date: .abbreviated, time: .omitted)))
                    Text(Strings.EstimateDetail.issued(estimate.issueDate.formatted(date: .numeric, time: .omitted)))
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EstimateStateIndicator: View {
    let state: EstimateState

    private var color: Color {
        switch state {
        case .draft: .gray
        case .sent: .orange
        case .accepted: .green
        case .declined: .red
        }
    }

    var body: some View {
        Text(state.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

struct EstimateExportProgressOverlay: View {
    let progress: Double
    let message: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView(value: progress) {
                    Text(Strings.EstimatesList.exportingEstimates).font(.headline)
                } currentValueLabel: {
                    Text(message).font(.caption).foregroundStyle(.secondary)
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

#Preview {
    NavigationStack {
        EstimatesListView(viewModel: EstimatesViewModel())
    }
}
