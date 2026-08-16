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
        let historyStore = HistoryStoringDouble()
        let medicine = TestHelper.makeMedicine()
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicine: medicine, historyStore: historyStore)
        let entry = TestHelper.makeHistoryEntry()

        viewModel.listen()
        historyStore.emit([entry])
        await TestHelper.waitUntil { !viewModel.history.isEmpty }

        XCTAssertEqual(viewModel.history, [entry])
    }

    @MainActor
    func testApplyUpdate_calledWithMedicine_replacesMedicine() {
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicine: TestHelper.makeMedicine(name: "Doliprane"))
        let updated = TestHelper.makeMedicine(name: "Dafalgan")

        viewModel.applyUpdate(updated)

        XCTAssertEqual(viewModel.medicine, updated)
    }

    @MainActor
    func testIncrease_success_savesAndUpdatesLocalState() async {
        let medicineStore = MedicineStoringDouble()
        let historyStore = HistoryStoringDouble()
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
        let medicineStore = MedicineStoringDouble()
        let historyStore = HistoryStoringDouble()
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
        let medicineStore = MedicineStoringDouble()
        let historyStore = HistoryStoringDouble()
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
        let medicineStore = MedicineStoringDouble()
        let historyStore = HistoryStoringDouble()
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
    func testDelete_success_recordsHistoryAndMarksDeleted() async {
        let medicineStore = MedicineStoringDouble()
        let historyStore = HistoryStoringDouble()
        let aisleStore = AisleStoringDouble()
        let medicine = TestHelper.makeMedicine(aisle: "AD56")
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicine: medicine,
                                                               medicineStore: medicineStore,
                                                               historyStore: historyStore,
                                                               aisleStore: aisleStore)

        await viewModel.delete()

        XCTAssertEqual(medicineStore.deletedMedicines, [medicine])
        XCTAssertEqual(historyStore.deletedMedicines, [medicine])
        XCTAssertEqual(aisleStore.removedFromAisles, ["AD56"])
        XCTAssertTrue(viewModel.isDeleted)
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testDelete_storeFailure_setsTypedErrorAndSkipsHistory() async {
        let medicineStore = MedicineStoringDouble()
        let historyStore = HistoryStoringDouble()
        medicineStore.deleteError = MedicineError.network(.serverUnreachable)
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicineStore: medicineStore, historyStore: historyStore)

        await viewModel.delete()

        XCTAssertEqual(viewModel.error, .network(.serverUnreachable))
        XCTAssertFalse(viewModel.isDeleted)
        XCTAssertTrue(historyStore.deletedMedicines.isEmpty)
    }
}
