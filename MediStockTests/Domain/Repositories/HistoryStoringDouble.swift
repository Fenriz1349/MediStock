//
//  HistoryStoringDouble.swift
//  MediStockTests
//
//  Created by Julien Cotte on 12/08/2026.
//

import Foundation
@testable import MediStock

/// In-memory fake of `HistoryStoring` for testing, with a controllable history stream.
/// Tracks each kind of recorded change separately, matching the protocol's one-method-per-action shape.
final class HistoryStoringDouble: HistoryStoring {
    private(set) var addedMedicines: [Medicine] = []
    private(set) var updatedMedicines: [Medicine] = []
    private(set) var updateDetails: [(medicine: Medicine, previousName: String, previousAisle: String)] = []
    private(set) var stockChanges: [(medicine: Medicine, previousStock: Int)] = []
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

    func recordUpdate(of medicine: Medicine, previousName: String, previousAisle: String) async throws {
        if let recordError { throw recordError }
        updatedMedicines.append(medicine)
        updateDetails.append((medicine, previousName, previousAisle))
    }

    func recordStockChange(of medicine: Medicine, from previousStock: Int) async throws {
        if let recordError { throw recordError }
        stockChanges.append((medicine, previousStock))
    }
}
