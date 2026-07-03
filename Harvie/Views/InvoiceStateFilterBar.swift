//
//  InvoiceStateFilterBar.swift
//  Harvie
//

import SwiftUI

/// Always-visible chip row for filtering invoices by one or more states.
///
/// Plain click selects only that state (single-select). ⌘-click or Shift-click
/// toggles a state in or out to build a combination. "All" clears the filter
/// (empty set == every state).
struct InvoiceStateFilterBar: View {
    @Bindable var viewModel: InvoicesViewModel

    var body: some View {
        HStack(spacing: 6) {
            chip(
                title: Strings.InvoicesList.all,
                tint: .accentColor,
                isSelected: viewModel.selectedStates.isEmpty
            ) {
                viewModel.selectedStates = []
            }

            ForEach(InvoiceState.allCases, id: \.self) { state in
                chip(
                    title: title(for: state),
                    tint: state == .draft ? .primary : state.color,
                    isSelected: viewModel.selectedStates.contains(state)
                ) {
                    select(state)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .help(Strings.InvoicesList.stateFilterHint)
    }

    private func select(_ state: InvoiceState) {
        let modifiers = NSEvent.modifierFlags
        if modifiers.contains(.command) || modifiers.contains(.shift) {
            if viewModel.selectedStates.contains(state) {
                viewModel.selectedStates.remove(state)
            } else {
                viewModel.selectedStates.insert(state)
            }
        } else {
            viewModel.selectedStates = [state]
        }
    }

    private func chip(
        title: String,
        tint: Color,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(isSelected ? tint.opacity(0.22) : Color.secondary.opacity(0.12))
                .foregroundStyle(isSelected ? tint : Color.secondary)
                .clipShape(Capsule())
                .overlay {
                    Capsule().strokeBorder(isSelected ? tint.opacity(0.5) : .clear, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private func title(for state: InvoiceState) -> String {
        switch state {
        case .draft: Strings.InvoicesList.stateDraft
        case .open: Strings.InvoicesList.stateOpen
        case .paid: Strings.InvoicesList.statePaid
        case .closed: Strings.InvoicesList.stateClosed
        }
    }
}

/// Always-visible chip row for filtering estimates by one or more states.
struct EstimateStateFilterBar: View {
    @Bindable var viewModel: EstimatesViewModel

    var body: some View {
        HStack(spacing: 6) {
            chip(
                title: Strings.EstimatesList.all,
                tint: .accentColor,
                isSelected: viewModel.selectedStates.isEmpty
            ) {
                viewModel.selectedStates = []
            }

            ForEach(EstimateState.allCases, id: \.self) { state in
                chip(
                    title: title(for: state),
                    tint: tint(for: state),
                    isSelected: viewModel.selectedStates.contains(state)
                ) {
                    select(state)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .help(Strings.EstimatesList.stateFilterHint)
    }

    private func select(_ state: EstimateState) {
        let modifiers = NSEvent.modifierFlags
        if modifiers.contains(.command) || modifiers.contains(.shift) {
            if viewModel.selectedStates.contains(state) {
                viewModel.selectedStates.remove(state)
            } else {
                viewModel.selectedStates.insert(state)
            }
        } else {
            viewModel.selectedStates = [state]
        }
    }

    private func chip(
        title: String,
        tint: Color,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(isSelected ? tint.opacity(0.22) : Color.secondary.opacity(0.12))
                .foregroundStyle(isSelected ? tint : Color.secondary)
                .clipShape(Capsule())
                .overlay {
                    Capsule().strokeBorder(isSelected ? tint.opacity(0.5) : .clear, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private func title(for state: EstimateState) -> String {
        switch state {
        case .draft: Strings.EstimatesList.stateDraft
        case .sent: Strings.EstimatesList.stateSent
        case .accepted: Strings.EstimatesList.stateAccepted
        case .declined: Strings.EstimatesList.stateDeclined
        }
    }

    private func tint(for state: EstimateState) -> Color {
        switch state {
        case .draft: .primary
        case .sent: .orange
        case .accepted: .green
        case .declined: .red
        }
    }
}

#Preview {
    InvoiceStateFilterBar(viewModel: InvoicesViewModel())
}
