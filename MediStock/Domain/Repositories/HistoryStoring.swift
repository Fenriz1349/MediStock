//
//  HistoryStoring.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import Foundation

/// Read/write access to the medicine change audit trail.
/// One method per kind of change, so callers never build a `HistoryEntry` themselves, or know who the current user is.
/// The implementation resolves the acting user and the entry's wording on its own.
protocol HistoryStoring {
    /// An ongoing stream of history entries for a given medicine, most recent changes included.
    func observeHistory(forMedicineId medicineId: String) -> AsyncStream<[HistoryEntry]>

    /// Records that `medicine` was just created.
    func recordAddition(of medicine: Medicine) async throws

    /// Records that `medicine`'s name/aisle were just updated.
    /// `previousName`/`previousAisle` are the values before the edit.
    /// So the wording can say what actually changed instead of a generic "updated".
    func recordUpdate(of medicine: Medicine, previousName: String, previousAisle: String) async throws

    /// Records a stock change.
    /// `medicine` reflects the stock *after* the change; `previousStock` is the value before it.
    /// So the wording can say whether it was an increase or a decrease and by how much (not assumed to always be 1).
    func recordStockChange(of medicine: Medicine, from previousStock: Int) async throws
}
