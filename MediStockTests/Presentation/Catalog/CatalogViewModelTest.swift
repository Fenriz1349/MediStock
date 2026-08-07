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

        await viewModel.addMedicine(name: "Doliprane", stock: 10, aisle: "AD56", user: "user-1")

        XCTAssertEqual(medicineStore.savedMedicines, [TestHelper.makeMedicine(id: nil, name: "Doliprane", stock: 10, aisle: "AD56")])
        XCTAssertEqual(historyStore.recordedEntries.count, 1)
    }

    @MainActor
    func testDeleteCallsStore() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeCatalogViewModel(medicineStore: medicineStore)
        let medicine = TestHelper.makeMedicine()

        await viewModel.delete(medicine)

        XCTAssertEqual(medicineStore.deletedMedicines, [medicine])
    }
}

/// In-memory fake of `MedicineStoring` for testing, with a controllable medicines stream.
final class MockMedicineStoring: MedicineStoring {
    private(set) var savedMedicines: [Medicine] = []
    private(set) var deletedMedicines: [Medicine] = []

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

    func emit(_ medicines: [Medicine]) {
        medicinesContinuation.yield(medicines)
    }

    func save(_ medicine: Medicine) async throws -> Medicine {
        savedMedicines.append(medicine)
        var saved = medicine
        if saved.id == nil { saved.id = UUID().uuidString }
        return saved
    }

    func delete(_ medicine: Medicine) async throws {
        deletedMedicines.append(medicine)
    }
}

/// In-memory fake of `HistoryStoring` for testing, with a controllable history stream.
final class MockHistoryStoring: HistoryStoring {
    private(set) var recordedEntries: [HistoryEntry] = []

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

    func record(_ entry: HistoryEntry) async throws {
        recordedEntries.append(entry)
    }
}
