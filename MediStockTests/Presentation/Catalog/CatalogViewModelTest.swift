//
//  CatalogViewModelTest.swift
//  MediStockTests
//
//  Created by Julien Cotte on 04/08/2026.
//

import XCTest
@testable import MediStock

final class CatalogViewModelTest: XCTestCase {
    @MainActor
    func testListenPopulatesMedicines() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeCatalogViewModel(medicineStore: medicineStore)
        let medicine = TestHelper.makeMedicine()

        viewModel.listen()
        medicineStore.emit([medicine])
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }

        XCTAssertEqual(viewModel.medicines, [medicine])
    }

    @MainActor
    func testAislesAreDistinctAndSortedNumerically() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeCatalogViewModel(medicineStore: medicineStore)
        let medicines = [
            TestHelper.makeMedicine(id: "1", aisle: "AD10"),
            TestHelper.makeMedicine(id: "2", aisle: "AD2"),
            TestHelper.makeMedicine(id: "3", aisle: "AD2")
        ]

        viewModel.listen()
        medicineStore.emit(medicines)
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }

        // A plain string sort would put "AD10" before "AD2"; natural sort must not.
        XCTAssertEqual(viewModel.aisles, ["AD2", "AD10"])
    }

    @MainActor
    func testMedicinesInAisleFiltersCorrectly() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeCatalogViewModel(medicineStore: medicineStore)
        let medicines = [
            TestHelper.makeMedicine(id: "1", aisle: "Rayon A"),
            TestHelper.makeMedicine(id: "2", aisle: "Rayon B")
        ]

        viewModel.listen()
        medicineStore.emit(medicines)
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }

        XCTAssertEqual(viewModel.medicines(inAisle: "Rayon A").map(\.id), ["1"])
    }

    @MainActor
    func testMedicinesMatchingFiltersByName() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeCatalogViewModel(medicineStore: medicineStore)
        let medicines = [
            TestHelper.makeMedicine(id: "1", name: "Doliprane"),
            TestHelper.makeMedicine(id: "2", name: "Advil"),
            TestHelper.makeMedicine(id: "3", name: "Dafalgan")
        ]

        viewModel.listen()
        medicineStore.emit(medicines)
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }

        let result = viewModel.medicines(matching: "dol", sortedBy: .none)

        XCTAssertEqual(result.map(\.id), ["1"])
    }

    @MainActor
    func testMedicinesMatchingSortsByStock() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeCatalogViewModel(medicineStore: medicineStore)
        let medicines = [
            TestHelper.makeMedicine(id: "1", stock: 20),
            TestHelper.makeMedicine(id: "2", stock: 5),
            TestHelper.makeMedicine(id: "3", stock: 10)
        ]

        viewModel.listen()
        medicineStore.emit(medicines)
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }

        let result = viewModel.medicines(matching: "", sortedBy: .stock)

        XCTAssertEqual(result.map(\.id), ["2", "3", "1"])
    }

    @MainActor
    func testAddMedicineSavesAndRecordsHistory() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        let viewModel = TestHelper.makeCatalogViewModel(medicineStore: medicineStore, historyStore: historyStore)

        await viewModel.addMedicine(name: "Doliprane", stock: 10, aisle: "AD56")

        XCTAssertEqual(medicineStore.savedMedicines, [TestHelper.makeMedicine(id: nil,
                                                                              name: "Doliprane",
                                                                              stock: 10,
                                                                              aisle: "AD56")])
        XCTAssertEqual(historyStore.addedMedicines.count, 1)
        XCTAssertEqual(historyStore.addedMedicines.first?.name, "Doliprane")
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testAddMedicineSaveFailureSetsTypedErrorAndSkipsHistory() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        medicineStore.saveError = MedicineError.networkUnavailable
        let viewModel = TestHelper.makeCatalogViewModel(medicineStore: medicineStore, historyStore: historyStore)

        await viewModel.addMedicine(name: "Doliprane", stock: 10, aisle: "AD56")

        XCTAssertEqual(viewModel.error, .networkUnavailable)
        XCTAssertTrue(historyStore.addedMedicines.isEmpty)
    }

    @MainActor
    func testAddMedicineHistoryFailureSetsTypedError() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        historyStore.recordError = MedicineError.unknown
        let viewModel = TestHelper.makeCatalogViewModel(medicineStore: medicineStore, historyStore: historyStore)

        await viewModel.addMedicine(name: "Doliprane", stock: 10, aisle: "AD56")

        XCTAssertEqual(viewModel.error, .unknown)
    }

    @MainActor
    func testDeleteCallsStoreAndRecordsHistory() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        let viewModel = TestHelper.makeCatalogViewModel(medicineStore: medicineStore, historyStore: historyStore)
        let medicine = TestHelper.makeMedicine()

        await viewModel.delete(medicine)

        XCTAssertEqual(medicineStore.deletedMedicines, [medicine])
        XCTAssertEqual(historyStore.deletedMedicines, [medicine])
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testDeleteFailureSetsTypedErrorAndSkipsHistory() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        medicineStore.deleteError = MedicineError.permissionDenied
        let viewModel = TestHelper.makeCatalogViewModel(medicineStore: medicineStore, historyStore: historyStore)

        await viewModel.delete(TestHelper.makeMedicine())

        XCTAssertEqual(viewModel.error, .permissionDenied)
        XCTAssertTrue(historyStore.deletedMedicines.isEmpty)
    }

    @MainActor
    func testDeleteHistoryFailureSetsTypedError() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        historyStore.recordError = MedicineError.unknown
        let viewModel = TestHelper.makeCatalogViewModel(medicineStore: medicineStore, historyStore: historyStore)

        await viewModel.delete(TestHelper.makeMedicine())

        XCTAssertEqual(viewModel.error, .unknown)
    }
}

/// In-memory fake of `MedicineStoring` for testing, with a controllable medicines stream.
final class MockMedicineStoring: MedicineStoring {
    private(set) var savedMedicines: [Medicine] = []
    private(set) var deletedMedicines: [Medicine] = []
    private(set) var requestedSortOptions: [SortOption] = []
    private(set) var requestedAisles: [String] = []
    var saveError: Error?
    var deleteError: Error?

    private let medicinesStream: AsyncStream<[Medicine]>
    private let medicinesContinuation: AsyncStream<[Medicine]>.Continuation

    init() {
        var continuation: AsyncStream<[Medicine]>.Continuation!
        medicinesStream = AsyncStream { continuation = $0 }
        medicinesContinuation = continuation
    }

    func observeMedicines() -> AsyncStream<[Medicine]> {
        medicinesStream
    }

    func observeMedicines(sortedBy sortOption: SortOption) -> AsyncStream<[Medicine]> {
        requestedSortOptions.append(sortOption)
        return medicinesStream
    }

    func observeMedicines(inAisle aisle: String) -> AsyncStream<[Medicine]> {
        requestedAisles.append(aisle)
        return medicinesStream
    }

    func emit(_ medicines: [Medicine]) {
        medicinesContinuation.yield(medicines)
    }

    func save(_ medicine: Medicine) async throws -> Medicine {
        if let saveError { throw saveError }
        savedMedicines.append(medicine)
        var saved = medicine
        if saved.id == nil { saved.id = UUID().uuidString }
        return saved
    }

    func delete(_ medicine: Medicine) async throws {
        if let deleteError { throw deleteError }
        deletedMedicines.append(medicine)
    }
}

/// In-memory fake of `HistoryStoring` for testing, with a controllable history stream. Tracks each
/// kind of recorded change separately, matching the protocol's one-method-per-action shape.
final class MockHistoryStoring: HistoryStoring {
    private(set) var addedMedicines: [Medicine] = []
    private(set) var updatedMedicines: [Medicine] = []
    private(set) var stockChanges: [(medicine: Medicine, previousStock: Int)] = []
    private(set) var deletedMedicines: [Medicine] = []
    var recordError: Error?

    private let historyStream: AsyncStream<[HistoryEntry]>
    private let historyContinuation: AsyncStream<[HistoryEntry]>.Continuation

    init() {
        var continuation: AsyncStream<[HistoryEntry]>.Continuation!
        historyStream = AsyncStream { continuation = $0 }
        historyContinuation = continuation
    }

    func observeHistory(forMedicineId medicineId: String) -> AsyncStream<[HistoryEntry]> {
        historyStream
    }

    func emit(_ entries: [HistoryEntry]) {
        historyContinuation.yield(entries)
    }

    func recordAddition(of medicine: Medicine) async throws {
        if let recordError { throw recordError }
        addedMedicines.append(medicine)
    }

    func recordUpdate(of medicine: Medicine) async throws {
        if let recordError { throw recordError }
        updatedMedicines.append(medicine)
    }

    func recordStockChange(of medicine: Medicine, from previousStock: Int) async throws {
        if let recordError { throw recordError }
        stockChanges.append((medicine, previousStock))
    }

    func recordDeletion(of medicine: Medicine) async throws {
        if let recordError { throw recordError }
        deletedMedicines.append(medicine)
    }
}
