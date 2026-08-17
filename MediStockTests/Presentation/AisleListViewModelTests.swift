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
    func testListen_aislesEmitted_populatesSortedAisles() async {
        let aisleStore = AisleStoringDouble()
        let viewModel = TestHelper.makeAisleListViewModel(aisleStore: aisleStore)
        let aisles = [
            AisleSummary(code: "AD10", medicineCount: 1),
            AisleSummary(code: "AD2", medicineCount: 2)
        ]

        viewModel.listen()
        aisleStore.emit(aisles)
        await TestHelper.waitUntil { !viewModel.aisles.isEmpty }

        // A plain string sort would put "AD10" before "AD2"; natural sort must not.
        XCTAssertEqual(viewModel.aisles, ["AD2", "AD10"])
    }

    @MainActor
    func testListen_subsequentEmission_updatesAisles() async {
        let aisleStore = AisleStoringDouble()
        let viewModel = TestHelper.makeAisleListViewModel(aisleStore: aisleStore)

        viewModel.listen()
        aisleStore.emit([AisleSummary(code: "AD2", medicineCount: 1)])
        await TestHelper.waitUntil { !viewModel.aisles.isEmpty }
        aisleStore.emit([AisleSummary(code: "AD2", medicineCount: 1), AisleSummary(code: "AD5", medicineCount: 1)])
        await TestHelper.waitUntil { viewModel.aisles.count == 2 }

        XCTAssertEqual(viewModel.aisles, ["AD2", "AD5"])
    }

    @MainActor
    func testMedicineCount_forKnownAisle_returnsStoredCount() async {
        let aisleStore = AisleStoringDouble()
        let viewModel = TestHelper.makeAisleListViewModel(aisleStore: aisleStore)
        viewModel.listen()
        aisleStore.emit([AisleSummary(code: "AD2", medicineCount: 3)])
        await TestHelper.waitUntil { !viewModel.aisles.isEmpty }

        XCTAssertEqual(viewModel.medicineCount(forAisle: "AD2"), 3)
    }

    @MainActor
    func testMedicineCount_forUnknownAisle_returnsZero() {
        let viewModel = TestHelper.makeAisleListViewModel()

        XCTAssertEqual(viewModel.medicineCount(forAisle: "AD2"), 0)
    }

    @MainActor
    func testAisles_sortAscendingFalse_reversesOrder() async {
        let aisleStore = AisleStoringDouble()
        let viewModel = TestHelper.makeAisleListViewModel(aisleStore: aisleStore)
        viewModel.listen()
        aisleStore.emit([AisleSummary(code: "AD2", medicineCount: 1), AisleSummary(code: "AD10", medicineCount: 1)])
        await TestHelper.waitUntil { !viewModel.aisles.isEmpty }

        viewModel.sortAscending = false

        XCTAssertEqual(viewModel.aisles, ["AD10", "AD2"])
    }

    @MainActor
    func testAisles_filterText_matchesSubstringAnywhere() async {
        let aisleStore = AisleStoringDouble()
        let viewModel = TestHelper.makeAisleListViewModel(aisleStore: aisleStore)
        viewModel.listen()
        aisleStore.emit([AisleSummary(code: "AD2", medicineCount: 1), AisleSummary(code: "BD5", medicineCount: 1)])
        await TestHelper.waitUntil { !viewModel.aisles.isEmpty }

        viewModel.filterText = "d2"

        XCTAssertEqual(viewModel.aisles, ["AD2"])
    }

    @MainActor
    func testAisles_filterTextEmpty_returnsEverything() async {
        let aisleStore = AisleStoringDouble()
        let viewModel = TestHelper.makeAisleListViewModel(aisleStore: aisleStore)
        viewModel.listen()
        aisleStore.emit([AisleSummary(code: "AD2", medicineCount: 1), AisleSummary(code: "BD5", medicineCount: 1)])
        await TestHelper.waitUntil { !viewModel.aisles.isEmpty }

        XCTAssertEqual(viewModel.aisles, ["AD2", "BD5"])
    }
}
