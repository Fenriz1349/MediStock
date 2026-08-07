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
    func testListenPopulatesHistory() async {
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
    func testUpdateLabelSavesAndRecordsHistory() async {
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
    func testUpdateLabelSaveFailureSetsTypedErrorAndSkipsHistory() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        medicineStore.saveError = MedicineError.networkUnavailable
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicineStore: medicineStore, historyStore: historyStore)

        await viewModel.updateLabel(name: "Dafalgan", aisle: "AD10")

        XCTAssertEqual(viewModel.error, .networkUnavailable)
        XCTAssertTrue(historyStore.updatedMedicines.isEmpty)
    }

    @MainActor
    func testIncreaseSavesIncrementedMedicineAndUpdatesLocalState() async {
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
    func testIncreaseSaveFailureSetsTypedErrorAndSkipsHistory() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        medicineStore.saveError = MedicineError.networkUnavailable
        let medicine = TestHelper.makeMedicine(stock: 10)
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicine: medicine,
                                                               medicineStore: medicineStore,
                                                               historyStore: historyStore)

        await viewModel.increase()

        XCTAssertEqual(viewModel.error, .networkUnavailable)
        XCTAssertEqual(viewModel.medicine.stock, 10)
        XCTAssertTrue(historyStore.stockChanges.isEmpty)
    }

    @MainActor
    func testIncreaseHistoryFailureSetsTypedError() async {
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
    func testDecreaseSavesDecrementedMedicineAndUpdatesLocalState() async {
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
    func testDeleteCallsStoreAndRecordsHistory() async {
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
    func testDeleteFailureSetsTypedErrorAndSkipsHistory() async {
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
    func testDeleteHistoryFailureSetsTypedError() async {
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
