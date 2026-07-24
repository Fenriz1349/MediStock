//
//  HistoryStoring.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import Foundation

/// Read/write access to the medicine change audit trail.
protocol HistoryStoring {
    /// An ongoing stream of history entries for a given medicine, most recent changes included.
    func observeHistory(forMedicineId medicineId: String) -> AsyncStream<[HistoryEntry]>

    /// Records a new audit entry. Must be called for every mutation of a medicine.
    func record(_ entry: HistoryEntry) async throws
}
