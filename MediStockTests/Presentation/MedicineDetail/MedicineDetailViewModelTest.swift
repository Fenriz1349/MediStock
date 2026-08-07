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
        XCTAssertEqual(historyStore.recordedEntries.count, 1)
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
        XCTAssertEqual(historyStore.recordedEntries.count, 1)
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
        XCTAssertEqual(historyStore.recordedEntries.count, 1)
    }

    @MainActor
    func testDeleteCallsStoreWithoutRecordingHistory() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        let medicine = TestHelper.makeMedicine()
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicine: medicine,
                                                               medicineStore: medicineStore,
                                                               historyStore: historyStore)

        await viewModel.delete()

        XCTAssertEqual(medicineStore.deletedMedicines, [medicine])
        XCTAssertTrue(historyStore.recordedEntries.isEmpty)
    }

    @MainActor
    func testSaveUsesCurrentSessionUser() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        let authenticationService = MockAuthenticationServicing()
        let medicine = TestHelper.makeMedicine()
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicine: medicine,
                                                               medicineStore: medicineStore,
                                                               historyStore: historyStore,
                                                               authenticationService: authenticationService)

        viewModel.listen()
        authenticationService.emit(TestHelper.makeAppUser(uid: "user-42"))

        // The session stream propagates asynchronously; retry the save until it has, instead of
        // guessing a fixed delay.
        var lastRecordedUser: String?
        let deadline = Date().addingTimeInterval(1)
        while lastRecordedUser != "user-42" && Date() < deadline {
            await viewModel.increase()
            lastRecordedUser = historyStore.recordedEntries.last?.user
        }

        XCTAssertEqual(lastRecordedUser, "user-42")
    }
}
