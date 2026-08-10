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
    func testAddMedicineNormalizesTheNameCapitalization() async {
        let medicineStore = MockMedicineStoring()
        let historyStore = MockHistoryStoring()
        let viewModel = TestHelper.makeCatalogViewModel(medicineStore: medicineStore, historyStore: historyStore)

        await viewModel.addMedicine(name: "dOLIPRANE", stock: 10, aisle: "AD56")

        XCTAssertEqual(medicineStore.savedMedicines.first?.name, "Doliprane")
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
    private(set) var requestedAscending: [Bool] = []
    private(set) var requestedAisles: [String] = []
    private(set) var requestedNamePrefixes: [String] = []
    var saveError: Error?
    var deleteError: Error?

    private let medicinesStream: AsyncStream<[Medicine]>
    private let medicinesContinuation: AsyncStream<[Medicine]>.Continuation
    /// Separate from `medicinesStream` so a test can re-subscribe (e.g. `sortOption` then `filterText`).
    /// No racing a stale subscription on the same shared stream that way.
    private let nameSearchStream: AsyncStream<[Medicine]>
    private let nameSearchContinuation: AsyncStream<[Medicine]>.Continuation

    init() {
        var continuation: AsyncStream<[Medicine]>.Continuation!
        medicinesStream = AsyncStream { continuation = $0 }
        medicinesContinuation = continuation
        var searchContinuation: AsyncStream<[Medicine]>.Continuation!
        nameSearchStream = AsyncStream { searchContinuation = $0 }
        nameSearchContinuation = searchContinuation
    }

    func observeMedicines() -> AsyncStream<[Medicine]> {
        medicinesStream
    }

    func observeMedicines(sortedBy sortOption: SortOption, ascending: Bool) -> AsyncStream<[Medicine]> {
        requestedSortOptions.append(sortOption)
        requestedAscending.append(ascending)
        return medicinesStream
    }

    func observeMedicines(inAisle aisle: String) -> AsyncStream<[Medicine]> {
        requestedAisles.append(aisle)
        return medicinesStream
    }

    func observeMedicines(nameStartingWith prefix: String) -> AsyncStream<[Medicine]> {
        requestedNamePrefixes.append(prefix)
        return nameSearchStream
    }

    func emit(_ medicines: [Medicine]) {
        medicinesContinuation.yield(medicines)
    }

    func emitSearchResults(_ medicines: [Medicine]) {
        nameSearchContinuation.yield(medicines)
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

/// In-memory fake of `HistoryStoring` for testing, with a controllable history stream.
/// Tracks each kind of recorded change separately, matching the protocol's one-method-per-action shape.
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
