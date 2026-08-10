//
//  MedicineDetailViewModelTest.swift
//  MediStockTests
//
//  Created by Julien Cotte on 04/08/2026.
//

import XCTest
@testable import MediStock

final class MedicineDetailViewModelTest: XCTestCase {
    @MainActor
    func testListen_historyEmitted_populatesHistory() async {
        let historyStore = MockHistoryStoring()
        let medicine = TestHelper.makeMedicine()
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicine: medicine, historyStore: historyStore)
        let entry = TestHelper.makeHistoryEntry()

        viewModel.listen()
        historyStore.emit([entry])
        await TestHelper.waitUntil { !viewModel.history.isEmpty }

        XCTAssertEqual(viewModel.history, [entry])
    }

    @MainActor
    func testUpdateLabel_success_savesAndRecordsHistory() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        let medicine = TestHelper.makeMedicine(name: "Doliprane", aisle: "AD56")
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicine: medicine,
                                                               medicineStore: medicineStore,
                                                               historyStore: historyStore)

        await viewModel.updateLabel(name: "Dafalgan", aisle: "AD10")

        XCTAssertEqual(medicineStore.savedMedicines.first?.name, "Dafalgan")
        XCTAssertEqual(medicineStore.savedMedicines.first?.aisle, "AD10")
        XCTAssertEqual(historyStore.updatedMedicines.count, 1)
        XCTAssertEqual(historyStore.updatedMedicines.first?.name, "Dafalgan")
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testUpdateLabel_inFlight_togglesIsLoading() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        let networkMonitor = MockNetworkMonitoring()
        networkMonitor.verifyReachableDelayNanoseconds = 50_000_000
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicineStore: medicineStore,
                                                                historyStore: historyStore,
                                                                networkMonitor: networkMonitor)
        XCTAssertFalse(viewModel.isLoading)

        let task = Task { await viewModel.updateLabel(name: "Dafalgan", aisle: "AD10") }
        await TestHelper.waitUntil { viewModel.isLoading }
        XCTAssertTrue(viewModel.isLoading)

        await task.value

        XCTAssertFalse(viewModel.isLoading)
    }

    @MainActor
    func testUpdateLabel_name_normalizesCapitalization() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicineStore: medicineStore, historyStore: historyStore)

        await viewModel.updateLabel(name: "dAFALGAN", aisle: "AD10")

        XCTAssertEqual(medicineStore.savedMedicines.first?.name, "Dafalgan")
    }

    @MainActor
    func testUpdateLabel_saveFailure_setsTypedErrorAndSkipsHistory() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        medicineStore.saveError = MedicineError.network(.serverUnreachable)
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicineStore: medicineStore, historyStore: historyStore)

        await viewModel.updateLabel(name: "Dafalgan", aisle: "AD10")

        XCTAssertEqual(viewModel.error, .network(.serverUnreachable))
        XCTAssertTrue(historyStore.updatedMedicines.isEmpty)
    }

    @MainActor
    func testUpdateLabel_networkUnreachable_skipsStore() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        let networkMonitor = MockNetworkMonitoring()
        networkMonitor.verifyReachableError = .notConnected
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicineStore: medicineStore,
                                                                historyStore: historyStore,
                                                                networkMonitor: networkMonitor)

        await viewModel.updateLabel(name: "Dafalgan", aisle: "AD10")

        XCTAssertEqual(viewModel.error, .network(.notConnected))
        XCTAssertTrue(medicineStore.savedMedicines.isEmpty)
    }

    @MainActor
    func testIncrease_success_savesAndUpdatesLocalState() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        let medicine = TestHelper.makeMedicine(stock: 10)
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicine: medicine,
                                                               medicineStore: medicineStore,
                                                               historyStore: historyStore)

        await viewModel.increase()

        XCTAssertEqual(medicineStore.savedMedicines.first?.stock, 11)
        XCTAssertEqual(viewModel.medicine.stock, 11)
        XCTAssertEqual(historyStore.stockChanges.count, 1)
        XCTAssertEqual(historyStore.stockChanges.first?.medicine.stock, 11)
        XCTAssertEqual(historyStore.stockChanges.first?.previousStock, 10)
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testIncrease_saveFailure_setsTypedErrorAndSkipsHistory() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        medicineStore.saveError = MedicineError.network(.serverUnreachable)
        let medicine = TestHelper.makeMedicine(stock: 10)
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicine: medicine,
                                                               medicineStore: medicineStore,
                                                               historyStore: historyStore)

        await viewModel.increase()

        XCTAssertEqual(viewModel.error, .network(.serverUnreachable))
        XCTAssertEqual(viewModel.medicine.stock, 10)
        XCTAssertTrue(historyStore.stockChanges.isEmpty)
    }

    @MainActor
    func testIncrease_historyFailure_setsTypedError() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        historyStore.recordError = MedicineError.unknown
        let medicine = TestHelper.makeMedicine(stock: 10)
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicine: medicine,
                                                               medicineStore: medicineStore,
                                                               historyStore: historyStore)

        await viewModel.increase()

        XCTAssertEqual(viewModel.error, .unknown)
        XCTAssertEqual(viewModel.medicine.stock, 11) // the medicine save itself still succeeded
    }

    @MainActor
    func testDecrease_success_savesAndUpdatesLocalState() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        let medicine = TestHelper.makeMedicine(stock: 10)
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicine: medicine,
                                                               medicineStore: medicineStore,
                                                               historyStore: historyStore)

        await viewModel.decrease()

        XCTAssertEqual(medicineStore.savedMedicines.first?.stock, 9)
        XCTAssertEqual(viewModel.medicine.stock, 9)
        XCTAssertEqual(historyStore.stockChanges.count, 1)
        XCTAssertEqual(historyStore.stockChanges.first?.medicine.stock, 9)
        XCTAssertEqual(historyStore.stockChanges.first?.previousStock, 10)
    }

    @MainActor
    func testDelete_success_callsStoreAndRecordsHistory() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        let medicine = TestHelper.makeMedicine()
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicine: medicine,
                                                               medicineStore: medicineStore,
                                                               historyStore: historyStore)

        await viewModel.delete()

        XCTAssertEqual(medicineStore.deletedMedicines, [medicine])
        XCTAssertEqual(historyStore.deletedMedicines, [medicine])
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testDelete_failure_setsTypedErrorAndSkipsHistory() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        medicineStore.deleteError = MedicineError.permissionDenied
        let medicine = TestHelper.makeMedicine()
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicine: medicine,
                                                               medicineStore: medicineStore,
                                                               historyStore: historyStore)

        await viewModel.delete()

        XCTAssertEqual(viewModel.error, .permissionDenied)
        XCTAssertTrue(historyStore.deletedMedicines.isEmpty)
    }

    @MainActor
    func testDelete_historyFailure_setsTypedError() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        historyStore.recordError = MedicineError.unknown
        let medicine = TestHelper.makeMedicine()
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicine: medicine,
                                                               medicineStore: medicineStore,
                                                               historyStore: historyStore)

        await viewModel.delete()

        XCTAssertEqual(viewModel.error, .unknown)
    }
}
