//
//  AddMedicineViewModelTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 11/08/2026.
//

import XCTest
@testable import MediStock

final class AddMedicineViewModelTests: XCTestCase {
    @MainActor
    func testSave_success_savesAndRecordsHistory() async {
        let medicineStore = MedicineStoringDouble()
        let historyStore = HistoryStoringDouble()
        let viewModel = TestHelper.makeAddMedicineViewModel(medicineStore: medicineStore, historyStore: historyStore)
        viewModel.name = "Doliprane"
        viewModel.stockText = "10"

        await viewModel.save(cleanedAisle: "AD56")

        XCTAssertEqual(medicineStore.savedMedicines, [TestHelper.makeMedicine(id: nil,
                                                                              name: "Doliprane",
                                                                              stock: 10,
                                                                              aisle: "AD56")])
        XCTAssertEqual(historyStore.addedMedicines.count, 1)
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testSave_name_normalizesCapitalization() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAddMedicineViewModel(medicineStore: medicineStore)
        viewModel.name = "dOLIPRANE"
        viewModel.stockText = "10"

        await viewModel.save(cleanedAisle: "AD56")

        XCTAssertEqual(medicineStore.savedMedicines.first?.name, "Doliprane")
    }

    @MainActor
    func testSave_invalidStockText_defaultsToZero() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeAddMedicineViewModel(medicineStore: medicineStore)
        viewModel.name = "Doliprane"
        viewModel.stockText = "not-a-number"

        await viewModel.save(cleanedAisle: "AD56")

        XCTAssertEqual(medicineStore.savedMedicines.first?.stock, 0)
    }

    @MainActor
    func testSave_saveFailure_setsTypedErrorAndSkipsHistory() async {
        let medicineStore = MedicineStoringDouble()
        let historyStore = HistoryStoringDouble()
        medicineStore.saveError = MedicineError.network(.serverUnreachable)
        let viewModel = TestHelper.makeAddMedicineViewModel(medicineStore: medicineStore, historyStore: historyStore)

        await viewModel.save(cleanedAisle: "AD56")

        XCTAssertEqual(viewModel.error, .network(.serverUnreachable))
        XCTAssertTrue(historyStore.addedMedicines.isEmpty)
    }

    @MainActor
    func testSave_historyFailure_setsTypedError() async {
        let historyStore = HistoryStoringDouble()
        historyStore.recordError = MedicineError.unknown
        let viewModel = TestHelper.makeAddMedicineViewModel(historyStore: historyStore)

        await viewModel.save(cleanedAisle: "AD56")

        XCTAssertEqual(viewModel.error, .unknown)
    }

    @MainActor
    func testSave_networkUnreachable_skipsStore() async {
        let medicineStore = MedicineStoringDouble()
        let networkMonitor = NetworkMonitoringDouble()
        networkMonitor.verifyReachableError = .notConnected
        let viewModel = TestHelper.makeAddMedicineViewModel(medicineStore: medicineStore, networkMonitor: networkMonitor)

        await viewModel.save(cleanedAisle: "AD56")

        XCTAssertEqual(viewModel.error, .network(.notConnected))
        XCTAssertTrue(medicineStore.savedMedicines.isEmpty)
    }

    @MainActor
    func testSave_inFlight_togglesIsLoading() async {
        let networkMonitor = NetworkMonitoringDouble()
        networkMonitor.verifyReachableDelayNanoseconds = 50_000_000
        let viewModel = TestHelper.makeAddMedicineViewModel(networkMonitor: networkMonitor)
        XCTAssertFalse(viewModel.isLoading)

        let task = Task { await viewModel.save(cleanedAisle: "AD56") }
        await TestHelper.waitUntil { viewModel.isLoading }
        XCTAssertTrue(viewModel.isLoading)

        await task.value

        XCTAssertFalse(viewModel.isLoading)
    }

    @MainActor
    func testIsFormValid_allFieldsValid_returnsTrue() {
        let viewModel = TestHelper.makeAddMedicineViewModel()
        viewModel.name = "Doliprane"
        viewModel.aisle = "AD56"
        viewModel.stockText = "10"

        XCTAssertTrue(viewModel.isFormValid)
    }

    @MainActor
    func testIsFormValid_oneFieldInvalid_returnsFalse() {
        let viewModel = TestHelper.makeAddMedicineViewModel()
        viewModel.name = "Doliprane"
        viewModel.aisle = ""
        viewModel.stockText = "10"

        XCTAssertFalse(viewModel.isFormValid)
    }

    @MainActor
    func testIsFormValid_defaultState_returnsFalse() {
        let viewModel = TestHelper.makeAddMedicineViewModel()

        XCTAssertFalse(viewModel.isFormValid)
    }
}
