//
//  AisleListViewModelTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 10/08/2026.
//

import XCTest
@testable import MediStock

final class AisleListViewModelTests: XCTestCase {
    @MainActor
    func testListenPopulatesDistinctSortedAisles() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeAisleListViewModel(medicineStore: medicineStore)
        let medicines = [
            TestHelper.makeMedicine(id: "1", aisle: "AD10"),
            TestHelper.makeMedicine(id: "2", aisle: "AD2"),
            TestHelper.makeMedicine(id: "3", aisle: "AD2")
        ]

        viewModel.listen()
        medicineStore.emit(medicines)
        await TestHelper.waitUntil { !viewModel.aisles.isEmpty }

        // A plain string sort would put "AD10" before "AD2"; natural sort must not, and "AD2"
        // must appear once despite two medicines sharing it.
        XCTAssertEqual(viewModel.aisles, ["AD2", "AD10"])
    }

    @MainActor
    func testListenReflectsSubsequentEmissions() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeAisleListViewModel(medicineStore: medicineStore)

        viewModel.listen()
        medicineStore.emit([TestHelper.makeMedicine(aisle: "AD2")])
        await TestHelper.waitUntil { !viewModel.aisles.isEmpty }
        medicineStore.emit([TestHelper.makeMedicine(aisle: "AD2"), TestHelper.makeMedicine(id: "2", aisle: "AD5")])
        await TestHelper.waitUntil { viewModel.aisles.count == 2 }

        XCTAssertEqual(viewModel.aisles, ["AD2", "AD5"])
    }

    @MainActor
    func testSortAscendingFalseReversesTheOrder() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeAisleListViewModel(medicineStore: medicineStore)
        viewModel.listen()
        medicineStore.emit([TestHelper.makeMedicine(id: "1", aisle: "AD2"), TestHelper.makeMedicine(id: "2", aisle: "AD10")])
        await TestHelper.waitUntil { !viewModel.aisles.isEmpty }

        viewModel.sortAscending = false

        XCTAssertEqual(viewModel.aisles, ["AD10", "AD2"])
    }
}
