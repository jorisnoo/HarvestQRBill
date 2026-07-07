//
//  MultiSelectionView.swift
//  Harvie
//

import SwiftUI

struct MultiSelectionView: View {
    @Bindable var viewModel: InvoicesViewModel

    private var selectedInvoices: [Invoice] {
        viewModel.selectedInvoices
    }

    // Selections can mix currencies — show one total per currency instead of
    // summing incomparable amounts into a single number.
    private var formattedTotal: String {
        Dictionary(grouping: selectedInvoices, by: \.currency)
            .map { (currency: $0.key, total: $0.value.reduce(0) { $0 + $1.displayAmount }) }
            .sorted { $0.currency < $1.currency }
            .map { CurrencyFormatter.format($0.total, currency: $0.currency) }
            .joined(separator: " · ")
    }

    private var uniqueClients: Int {
        Set(selectedInvoices.map { $0.client.id }).count
    }

    var body: some View {
        VStack(spacing: 24) {
            headerSection
            summaryStats
            actionButtons

            if viewModel.allSelectedAreDrafts || viewModel.allSelectedAreOpen {
                changeDateButton
            }

            if viewModel.allSelectedAreDrafts {
                markAsSentButton
            }

            if viewModel.allSelectedAreOpen {
                openActionsSection
            }

            if viewModel.allSelectedArePaid {
                markAsOpenButton
            }

            Divider()
                .padding(.horizontal, 40)
            invoicesList
        }
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var changeDateButton: some View {
        Button {
            viewModel.initiateChangeDate()
        } label: {
            Label(Strings.InvoiceDetail.changeDate, systemImage: "calendar")
                .frame(maxWidth: 150)
        }
        .buttonStyle(.bordered)
        .disabled(viewModel.isUpdating)
    }

    private var markAsSentButton: some View {
        Button {
            viewModel.initiateMarkAsSent()
        } label: {
            Label(Strings.InvoiceDetail.markAsSent, systemImage: "paperplane")
                .frame(maxWidth: 150)
        }
        .buttonStyle(.bordered)
        .disabled(viewModel.isUpdating)
    }

    private var openActionsSection: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.initiateMarkAsPaid()
            } label: {
                Label(Strings.InvoiceDetail.markAsPaid, systemImage: "banknote")
                    .frame(maxWidth: 150)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isUpdating)

            Button {
                viewModel.showMarkAsDraftSheet = true
            } label: {
                Label(Strings.InvoiceDetail.markAsDraft, systemImage: "arrow.uturn.backward")
                    .frame(maxWidth: 150)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isUpdating)
        }
    }

    private var markAsOpenButton: some View {
        Button {
            viewModel.showMarkAsOpenSheet = true
        } label: {
            Label(Strings.InvoiceDetail.markAsOpen, systemImage: "arrow.uturn.backward")
                .frame(maxWidth: 150)
        }
        .buttonStyle(.bordered)
        .disabled(viewModel.isUpdating)
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.on.doc.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(Strings.MultiSelection.invoicesSelected(selectedInvoices.count))
                .font(.title2)
                .fontWeight(.semibold)
        }
    }

    private var summaryStats: some View {
        HStack(spacing: 24) {
            VStack {
                Text(Strings.MultiSelection.total)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formattedTotal)
                    .font(.title3)
                    .fontWeight(.medium)
            }

            Divider().frame(height: 32)

            VStack {
                Text(Strings.MultiSelection.clients)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(uniqueClients)")
                    .font(.title3)
                    .fontWeight(.medium)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await viewModel.exportSelectedInvoices(withQRBill: true)
                }
            } label: {
                Label(Strings.InvoicesList.exportWithQRBill, systemImage: "qrcode")
                    .frame(maxWidth: 220)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!viewModel.canExportWithQRBill)

            Button {
                Task {
                    await viewModel.exportSelectedInvoices(withQRBill: false)
                }
            } label: {
                Label(Strings.InvoicesList.exportWithoutQRBill, systemImage: "doc.text")
                    .frame(maxWidth: 220)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    private var invoicesList: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(selectedInvoices) { invoice in
                    HStack {
                        Text(invoice.number)
                            .fontWeight(.medium)
                        Text(Strings.MultiSelection.bullet)
                            .foregroundStyle(.tertiary)
                        Text(invoice.client.name)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(CurrencyFormatter.format(invoice.displayAmount, currency: invoice.currency))
                            .foregroundStyle(.secondary)
                    }
                    .font(.callout)
                }
            }
            .padding(.horizontal, 40)
        }
    }
}
