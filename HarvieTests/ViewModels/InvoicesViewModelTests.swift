//
//  InvoicesViewModelTests.swift
//  HarvieTests
//

import Testing
@testable import Harvie

@Suite("Invoices ViewModel")
struct InvoicesViewModelTests {

    @Test("Deselect all clears all selections")
    @MainActor
    func deselectAll() {
        let vm = InvoicesViewModel()
        vm.selectedInvoiceIDs = [1, 2, 3, 4, 5]

        vm.deselectAll()

        #expect(vm.selectedInvoiceIDs.isEmpty)
    }

    @Test("Sort direction toggle switches between ascending and descending")
    @MainActor
    func sortDirectionToggle() {
        var direction = SortDirection.ascending

        direction.toggle()
        #expect(direction == .descending)

        direction.toggle()
        #expect(direction == .ascending)
    }

    @Test("Default selected state is open")
    @MainActor
    func defaultStateFilter() {
        let vm = InvoicesViewModel()

        #expect(vm.selectedStates == [.open])
    }

    @Test("Default sort option is issue date")
    @MainActor
    func defaultSortOption() {
        let vm = InvoicesViewModel()

        #expect(vm.sortOption == .issueDate)
    }

    @Test("Default sort direction is descending")
    @MainActor
    func defaultSortDirection() {
        let vm = InvoicesViewModel()

        #expect(vm.sortDirection == .descending)
    }

    @Test("Valid sort options for draft filter")
    @MainActor
    func validSortOptionsForDraft() {
        let vm = InvoicesViewModel()
        vm.selectedStates = [.draft]

        #expect(vm.validSortOptions == [.issueDate])
    }

    @Test("Valid sort options for open filter")
    @MainActor
    func validSortOptionsForOpen() {
        let vm = InvoicesViewModel()
        vm.selectedStates = [.open]

        #expect(vm.validSortOptions == [.issueDate, .dueDate])
    }

    @Test("Valid sort options for paid filter includes all options")
    @MainActor
    func validSortOptionsForPaid() {
        let vm = InvoicesViewModel()
        vm.selectedStates = [.paid]

        #expect(vm.validSortOptions == InvoiceSortOption.allCases)
    }

    @Test("All selected are drafts returns false when empty")
    @MainActor
    func allSelectedAreDraftsEmpty() {
        let vm = InvoicesViewModel()

        #expect(!vm.allSelectedAreDrafts)
    }

    @Test("All selected are open returns false when empty")
    @MainActor
    func allSelectedAreOpenEmpty() {
        let vm = InvoicesViewModel()

        #expect(!vm.allSelectedAreOpen)
    }

    @Test("Can export with QR bill when creditor info is valid")
    @MainActor
    func canExportWithQRBill() {
        let vm = InvoicesViewModel()
        vm.creditorInfo = CreditorInfo(
            iban: "CH9300762011623852957",
            name: "Test Company",
            streetName: "Test Street",
            buildingNumber: "1",
            postalCode: "8000",
            town: "Zurich",
            country: "CH"
        )

        #expect(vm.canExportWithQRBill)
    }

    @Test("Cannot export with QR bill when creditor info is invalid")
    @MainActor
    func cannotExportWithQRBillInvalidCreditor() {
        let vm = InvoicesViewModel()
        vm.creditorInfo = .empty

        #expect(!vm.canExportWithQRBill)
    }
}

@Suite("Estimates ViewModel")
struct EstimatesViewModelTests {
    @Test("Default selected state is sent")
    @MainActor
    func defaultSelectedState() {
        let vm = EstimatesViewModel()

        #expect(vm.selectedStates == [.sent])
    }

    @Test("Filters estimates by multiple selected states")
    @MainActor
    func multipleStateFiltering() {
        let vm = EstimatesViewModel()
        vm.selectedStates = [.sent, .accepted]
        vm.estimates = [
            estimate(id: 1, state: .draft),
            estimate(id: 2, state: .sent),
            estimate(id: 3, state: .accepted),
            estimate(id: 4, state: .declined),
        ]

        #expect(Set(vm.sortedEstimates.map(\.state)) == [.sent, .accepted])
    }

    @Test("Empty selected states shows all estimates")
    @MainActor
    func allStateFiltering() {
        let vm = EstimatesViewModel()
        vm.selectedStates = []
        vm.estimates = [
            estimate(id: 1, state: .draft),
            estimate(id: 2, state: .sent),
            estimate(id: 3, state: .accepted),
            estimate(id: 4, state: .declined),
        ]

        #expect(vm.sortedEstimates.count == EstimateState.allCases.count)
    }

    private static func estimate(id: Int, state: EstimateState) -> Estimate {
        Estimate(
            id: id,
            clientKey: "client-\(id)",
            number: "EST-\(id)",
            amount: 100,
            currency: "EUR",
            state: state,
            issueDate: Date(timeIntervalSince1970: TimeInterval(id)),
            createdAt: .distantPast,
            updatedAt: .distantPast,
            client: ClientReference(id: id, name: "Client \(id)")
        )
    }
}
