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
    func testMedicines_sortOptionNone_keepsEmissionOrder() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAisleMedicinesViewModel(medicineStore: medicineStore)
        let zogzog = TestHelper.makeMedicine(id: "1", name: "Zogzog", stock: 5)
        let alpha = TestHelper.makeMedicine(id: "2", name: "Alpha", stock: 20)

        viewModel.listen()
        medicineStore.emit([zogzog, alpha])
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }

        XCTAssertEqual(viewModel.medicines, [zogzog, alpha])
    }

    @MainActor
    func testMedicines_sortOptionNameAscending_sortsAlphabetically() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAisleMedicinesViewModel(medicineStore: medicineStore)
        let zogzog = TestHelper.makeMedicine(id: "1", name: "Zogzog", stock: 5)
        let alpha = TestHelper.makeMedicine(id: "2", name: "Alpha", stock: 20)

        viewModel.listen()
        medicineStore.emit([zogzog, alpha])
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }
        viewModel.sortOption = .name
        viewModel.sortAscending = true

        XCTAssertEqual(viewModel.medicines, [alpha, zogzog])
    }

    @MainActor
    func testMedicines_sortOptionNameDescending_reversesAlphabeticalOrder() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAisleMedicinesViewModel(medicineStore: medicineStore)
        let zogzog = TestHelper.makeMedicine(id: "1", name: "Zogzog", stock: 5)
        let alpha = TestHelper.makeMedicine(id: "2", name: "Alpha", stock: 20)

        viewModel.listen()
        medicineStore.emit([zogzog, alpha])
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }
        viewModel.sortOption = .name
        viewModel.sortAscending = false

        XCTAssertEqual(viewModel.medicines, [zogzog, alpha])
    }

    @MainActor
    func testMedicines_sortOptionStockAscending_sortsByLowestStockFirst() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAisleMedicinesViewModel(medicineStore: medicineStore)
        let zogzog = TestHelper.makeMedicine(id: "1", name: "Zogzog", stock: 5)
        let alpha = TestHelper.makeMedicine(id: "2", name: "Alpha", stock: 20)

        viewModel.listen()
        medicineStore.emit([alpha, zogzog])
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }
        viewModel.sortOption = .stock
        viewModel.sortAscending = true

        XCTAssertEqual(viewModel.medicines, [zogzog, alpha])
    }

    @MainActor
    func testMedicines_sortOptionStockDescending_sortsByHighestStockFirst() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAisleMedicinesViewModel(medicineStore: medicineStore)
        let zogzog = TestHelper.makeMedicine(id: "1", name: "Zogzog", stock: 5)
        let alpha = TestHelper.makeMedicine(id: "2", name: "Alpha", stock: 20)

        viewModel.listen()
        medicineStore.emit([zogzog, alpha])
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }
        viewModel.sortOption = .stock
        viewModel.sortAscending = false

        XCTAssertEqual(viewModel.medicines, [alpha, zogzog])
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
