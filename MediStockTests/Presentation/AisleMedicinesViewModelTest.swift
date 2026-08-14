//
//  AisleMedicinesViewModelTest.swift
//  MediStockTests
//
//  Created by Julien Cotte on 10/08/2026.
//

import XCTest
@testable import MediStock

final class AisleMedicinesViewModelTest: XCTestCase {
    @MainActor
    func testAisle_afterInit_exposesConstructorValue() {
        let viewModel = TestHelper.makeAisleMedicinesViewModel(aisle: "AD56")

        XCTAssertEqual(viewModel.aisle, "AD56")
    }

    @MainActor
    func testListen_medicinesEmitted_populatesMedicines() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAisleMedicinesViewModel(medicineStore: medicineStore)
        let medicine = TestHelper.makeMedicine()

        viewModel.listen()
        medicineStore.emit([medicine])
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }

        XCTAssertEqual(viewModel.medicines, [medicine])
    }

    @MainActor
    func testListen_subsequentEmission_updatesMedicines() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAisleMedicinesViewModel(medicineStore: medicineStore)
        let first = TestHelper.makeMedicine(id: "1")
        let second = TestHelper.makeMedicine(id: "2")

        viewModel.listen()
        medicineStore.emit([first])
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }
        medicineStore.emit([first, second])
        await TestHelper.waitUntil { viewModel.medicines.count == 2 }

        XCTAssertEqual(viewModel.medicines, [first, second])
    }

    @MainActor
    func testListen_requestsAisleWithCurrentSortOptionAndDirection() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAisleMedicinesViewModel(aisle: "AD56", medicineStore: medicineStore)

        viewModel.listen()

        await TestHelper.waitUntil { !medicineStore.requestedAisles.isEmpty }
        XCTAssertEqual(medicineStore.requestedAisles, ["AD56"])
        XCTAssertEqual(medicineStore.requestedAisleSortOptions, [.none])
        XCTAssertEqual(medicineStore.requestedAisleAscending, [true])
    }

    @MainActor
    func testSortOption_changed_requeriesWithNewOption() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAisleMedicinesViewModel(medicineStore: medicineStore)
        viewModel.listen()
        await TestHelper.waitUntil { medicineStore.requestedAisleSortOptions == [.none] }

        viewModel.sortOption = .stock

        await TestHelper.waitUntil { medicineStore.requestedAisleSortOptions == [.none, .stock] }
        XCTAssertEqual(medicineStore.requestedAisleSortOptions, [.none, .stock])
    }

    @MainActor
    func testSortAscending_changed_requeriesWithNewDirection() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAisleMedicinesViewModel(medicineStore: medicineStore)
        viewModel.listen()
        await TestHelper.waitUntil { medicineStore.requestedAisleAscending == [true] }

        viewModel.sortAscending = false

        await TestHelper.waitUntil { medicineStore.requestedAisleAscending == [true, false] }
        XCTAssertEqual(medicineStore.requestedAisleAscending, [true, false])
    }

    @MainActor
    func testDelete_succeeds_recordsHistory() async {
        let medicineStore = MedicineStoringDouble()
        let historyStore = HistoryStoringDouble()
        let viewModel = TestHelper.makeAisleMedicinesViewModel(medicineStore: medicineStore, historyStore: historyStore)
        let medicine = TestHelper.makeMedicine()

        await viewModel.delete(medicine)

        XCTAssertEqual(medicineStore.deletedMedicines, [medicine])
        XCTAssertEqual(historyStore.deletedMedicines, [medicine])
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testDelete_storeThrows_exposesError() async {
        let medicineStore = MedicineStoringDouble()
        medicineStore.deleteError = MedicineError.unknown
        let viewModel = TestHelper.makeAisleMedicinesViewModel(medicineStore: medicineStore)

        await viewModel.delete(TestHelper.makeMedicine())

        XCTAssertEqual(viewModel.error, .unknown)
    }
}
