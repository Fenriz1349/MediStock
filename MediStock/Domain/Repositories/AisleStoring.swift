//
//  AisleStoring.swift
//  MediStock
//
//  Created by Julien Cotte on 16/08/2026.
//

import Foundation

/// Read/write access to the `aisles` collection — one query-optimization document per distinct aisle code.
/// Kept in sync with `medicines` writes.
/// Not a real Domain entity, no history of its own.
/// Every event that changes it is already recorded by `HistoryStoring` on the medicine side.
protocol AisleStoring {
    /// A live stream of every aisle that currently has at least one medicine.
    func observeAisles() -> AsyncStream<[AisleSummary]>

    /// Call once a medicine was just created or moved into `aisle`.
    func recordMedicineAdded(toAisle aisle: String) async throws

    /// Call once a medicine was just deleted from, or moved out of, `aisle`.
    func recordMedicineRemoved(fromAisle aisle: String) async throws
}
