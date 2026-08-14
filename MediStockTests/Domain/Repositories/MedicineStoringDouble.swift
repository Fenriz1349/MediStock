//
//  MedicineStoringDouble.swift
//  MediStockTests
//
//  Created by Julien Cotte on 12/08/2026.
//

import Foundation
@testable import MediStock

/// In-memory fake of `MedicineStoring` for testing, with a controllable medicines stream.
final class MedicineStoringDouble: MedicineStoring {
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
