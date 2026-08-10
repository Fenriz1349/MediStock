//
//  AllMedicinesViewModelTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 10/08/2026.
//

import XCTest
@testable import MediStock

final class AllMedicinesViewModelTests: XCTestCase {
    @MainActor
    func testListen_medicinesEmitted_populatesMedicines() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeAllMedicinesViewModel(medicineStore: medicineStore)
        let medicine = TestHelper.makeMedicine()

        viewModel.listen()
        medicineStore.emit([medicine])
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }

        XCTAssertEqual(viewModel.medicines, [medicine])
    }

    @MainActor
    func testSortOption_changed_requeriesWithNewOption() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeAllMedicinesViewModel(medicineStore: medicineStore)
        viewModel.listen()
        await TestHelper.waitUntil { medicineStore.requestedSortOptions == [.none] }

        viewModel.sortOption = .stock

        await TestHelper.waitUntil { medicineStore.requestedSortOptions == [.none, .stock] }
        XCTAssertEqual(medicineStore.requestedSortOptions, [.none, .stock])
    }

    @MainActor
    func testSortAscending_changed_requeriesWithNewDirection() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeAllMedicinesViewModel(medicineStore: medicineStore)
        viewModel.listen()
        await TestHelper.waitUntil { medicineStore.requestedAscending == [true] }

        viewModel.sortAscending = false

        await TestHelper.waitUntil { medicineStore.requestedAscending == [true, false] }
        XCTAssertEqual(medicineStore.requestedAscending, [true, false])
    }

    @MainActor
    func testFilterText_set_switchesToNamePrefixQuery() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeAllMedicinesViewModel(medicineStore: medicineStore)
        viewModel.listen()
        await TestHelper.waitUntil { medicineStore.requestedSortOptions == [.none] }

        viewModel.filterText = "Dol"

        await TestHelper.waitUntil { medicineStore.requestedNamePrefixes == ["Dol"] }
        XCTAssertEqual(medicineStore.requestedNamePrefixes, ["Dol"])
        // No further sorted-query re-fire while searching.
        XCTAssertEqual(medicineStore.requestedSortOptions, [.none])
    }

    @MainActor
    func testFilterText_cleared_switchesBackToSortedQuery() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeAllMedicinesViewModel(medicineStore: medicineStore)
        viewModel.listen()
        await TestHelper.waitUntil { medicineStore.requestedSortOptions == [.none] }
        viewModel.filterText = "Dol"
        await TestHelper.waitUntil { medicineStore.requestedNamePrefixes == ["Dol"] }

        viewModel.filterText = ""

        await TestHelper.waitUntil { medicineStore.requestedSortOptions == [.none, .none] }
        XCTAssertEqual(medicineStore.requestedSortOptions, [.none, .none])
    }

    @MainActor
    func testSearchResults_sortOptionSet_sortsLocally() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeAllMedicinesViewModel(medicineStore: medicineStore)
        viewModel.sortOption = .stock
        let doliprane = TestHelper.makeMedicine(id: "1", name: "Doliprane", stock: 20)
        let dolodent = TestHelper.makeMedicine(id: "2", name: "Dolodent", stock: 5)

        viewModel.filterText = "Dol"
        await TestHelper.waitUntil { medicineStore.requestedNamePrefixes == ["Dol"] }
        medicineStore.emitSearchResults([doliprane, dolodent])
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }

        // Sorted by stock ascending locally, even though the mock emitted doliprane first.
        XCTAssertEqual(viewModel.medicines.map(\.id), ["2", "1"])
    }
}
