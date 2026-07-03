//
//  InvoiceStateFilterBar.swift
//  Harvie
//

import SwiftUI

/// Always-visible chip row for filtering invoices by one or more states.
///
/// Plain click selects only that state (single-select). ⌘-click toggles a state
/// in or out to build a combination (Finder selection semantics). "All" clears
/// the filter (empty set == every state).
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
        if NSEvent.modifierFlags.contains(.command) {
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

#Preview {
    InvoiceStateFilterBar(viewModel: InvoicesViewModel())
}
