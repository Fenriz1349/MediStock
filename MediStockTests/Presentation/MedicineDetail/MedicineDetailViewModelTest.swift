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
        let viewModel = MedicineDetailViewModel(medicineStore: MockMedicineStoring(), historyStore: historyStore)
        let entry = TestHelper.makeHistoryEntry()

        viewModel.listen(forMedicineId: "medicine-1")
        historyStore.emit([entry])
        await TestHelper.waitUntil { !viewModel.history.isEmpty }

        XCTAssertEqual(viewModel.history, [entry])
    }

    @MainActor
    func testUpdateMedicineSavesAndRecordsHistory() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        let viewModel = MedicineDetailViewModel(medicineStore: medicineStore, historyStore: historyStore)
        let medicine = TestHelper.makeMedicine(name: "Doliprane")

        await viewModel.updateMedicine(medicine, user: "user-1")

        XCTAssertEqual(medicineStore.savedMedicines, [medicine])
        XCTAssertEqual(historyStore.recordedEntries.count, 1)
    }

    @MainActor
    func testIncreaseStockSavesIncrementedMedicine() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = MedicineDetailViewModel(medicineStore: medicineStore, historyStore: MockHistoryStoring())
        let medicine = TestHelper.makeMedicine(stock: 10)

        await viewModel.increaseStock(medicine, user: "user-1")

        XCTAssertEqual(medicineStore.savedMedicines.first?.stock, 11)
    }

    @MainActor
    func testDecreaseStockSavesDecrementedMedicine() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = MedicineDetailViewModel(medicineStore: medicineStore, historyStore: MockHistoryStoring())
        let medicine = TestHelper.makeMedicine(stock: 10)

        await viewModel.decreaseStock(medicine, user: "user-1")

        XCTAssertEqual(medicineStore.savedMedicines.first?.stock, 9)
    }
}
