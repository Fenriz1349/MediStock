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
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAllMedicinesViewModel(medicineStore: medicineStore)
        let medicine = TestHelper.makeMedicine()

        viewModel.listen()
        medicineStore.emit([medicine])
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }

        XCTAssertEqual(viewModel.medicines, [medicine])
    }

    @MainActor
    func testSortOption_changed_requeriesWithNewOption() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAllMedicinesViewModel(medicineStore: medicineStore)
        viewModel.listen()
        await TestHelper.waitUntil { medicineStore.requestedSortOptions == [.none] }

        viewModel.sortOption = .stock

        await TestHelper.waitUntil { medicineStore.requestedSortOptions == [.none, .stock] }
        XCTAssertEqual(medicineStore.requestedSortOptions, [.none, .stock])
    }

    @MainActor
    func testSortAscending_changed_requeriesWithNewDirection() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAllMedicinesViewModel(medicineStore: medicineStore)
        viewModel.listen()
        await TestHelper.waitUntil { medicineStore.requestedAscending == [true] }

        viewModel.sortAscending = false

        await TestHelper.waitUntil { medicineStore.requestedAscending == [true, false] }
        XCTAssertEqual(medicineStore.requestedAscending, [true, false])
    }

    @MainActor
    func testFilterText_set_switchesToNamePrefixQuery() async {
        let medicineStore = MedicineStoringDouble()
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
        let medicineStore = MedicineStoringDouble()
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
    func testSearchResults_sortOptionSet_ignoresSortAndKeepsServerOrder() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAllMedicinesViewModel(medicineStore: medicineStore)
        viewModel.sortOption = .stock
        let doliprane = TestHelper.makeMedicine(id: "1", name: "Doliprane", stock: 20)
        let dolodent = TestHelper.makeMedicine(id: "2", name: "Dolodent", stock: 5)

        viewModel.filterText = "Dol"
        await TestHelper.waitUntil { medicineStore.requestedNamePrefixes == ["Dol"] }
        medicineStore.emitSearchResults([doliprane, dolodent])
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }

        // No local sort — search results are used as returned by the store (Firestore's own name order).
        XCTAssertEqual(viewModel.medicines.map(\.id), ["1", "2"])
    }

    @MainActor
    func testListen_initially_requestsDefaultPageSize() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAllMedicinesViewModel(medicineStore: medicineStore)

        viewModel.listen()

        await TestHelper.waitUntil { !medicineStore.requestedLimits.isEmpty }
        XCTAssertEqual(medicineStore.requestedLimits, [viewModel.pageSize])
    }

    @MainActor
    func testLoadMore_resultsFillPageSize_raisesPageSizeAndRequeries() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAllMedicinesViewModel(medicineStore: medicineStore)
        viewModel.listen()
        let fullPage = (0..<viewModel.pageSize).map { TestHelper.makeMedicine(id: "\($0)") }
        medicineStore.emit(fullPage)
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }
        let initialPageSize = viewModel.pageSize

        viewModel.loadMore()

        await TestHelper.waitUntil { viewModel.pageSize > initialPageSize }
        XCTAssertEqual(medicineStore.requestedLimits, [initialPageSize, viewModel.pageSize])
    }

    @MainActor
    func testLoadMore_resultsUnderPageSize_isNoOp() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAllMedicinesViewModel(medicineStore: medicineStore)
        viewModel.listen()
        medicineStore.emit([TestHelper.makeMedicine()])
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }
        let initialPageSize = viewModel.pageSize

        viewModel.loadMore()

        XCTAssertEqual(viewModel.pageSize, initialPageSize)
        XCTAssertEqual(medicineStore.requestedLimits, [initialPageSize])
    }

    @MainActor
    func testFilterText_set_resetsPageSize() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAllMedicinesViewModel(medicineStore: medicineStore)
        viewModel.listen()
        let fullPage = (0..<viewModel.pageSize).map { TestHelper.makeMedicine(id: "\($0)") }
        medicineStore.emit(fullPage)
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }
        viewModel.loadMore()
        await TestHelper.waitUntil { medicineStore.requestedLimits.count == 2 }
        let raisedPageSize = viewModel.pageSize

        viewModel.filterText = "Dol"

        await TestHelper.waitUntil { medicineStore.requestedNamePrefixes == ["Dol"] }
        XCTAssertLessThan(viewModel.pageSize, raisedPageSize)
    }

    @MainActor
    func testDelete_succeeds_removesMedicineAndRecordsHistory() async {
        let medicineStore = MedicineStoringDouble()
        let historyStore = HistoryStoringDouble()
        let aisleStore = AisleStoringDouble()
        let viewModel = TestHelper.makeAllMedicinesViewModel(
            medicineStore: medicineStore,
            historyStore: historyStore,
            aisleStore: aisleStore
        )
        let medicine = TestHelper.makeMedicine(aisle: "AD56")

        await viewModel.delete(medicine)

        XCTAssertEqual(medicineStore.deletedMedicines, [medicine])
        XCTAssertEqual(historyStore.deletedMedicines, [medicine])
        XCTAssertEqual(aisleStore.removedFromAisles, ["AD56"])
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testDelete_storeThrows_exposesError() async {
        let medicineStore = MedicineStoringDouble()
        medicineStore.deleteError = MedicineError.unknown
        let viewModel = TestHelper.makeAllMedicinesViewModel(medicineStore: medicineStore)

        await viewModel.delete(TestHelper.makeMedicine())

        XCTAssertEqual(viewModel.error, .unknown)
    }
}
