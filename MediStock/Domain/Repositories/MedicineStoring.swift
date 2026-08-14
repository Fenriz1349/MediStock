//
//  MedicineStoring.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import Foundation

/// Read/write access to the medicine catalog, with live updates as the underlying data changes.
/// One method per real query need — filtering/sorting happens server-side wherever Firestore can express it.
protocol MedicineStoring {
    /// The full, unfiltered stream of the current medicine list.
    /// Used only where Firestore can't express the need as a query directly.
    /// E.g. deriving the distinct list of aisles — Firestore has no "distinct"/"group by" query.
    /// So that still has to happen in memory.
    func observeMedicines() -> AsyncStream<[Medicine]>

    /// Server-side sorted stream, with no name filter applied.
    /// - Parameters:
    ///   - sortOption: How to order the results.
    ///   - ascending: The sort direction. Ignored when `sortOption` is `.none`.
    func observeMedicines(sortedBy sortOption: SortOption, ascending: Bool) -> AsyncStream<[Medicine]>

    /// Server-side filtered stream of medicines in a given aisle.
    /// - Parameter aisle: The exact aisle code to filter on.
    func observeMedicines(inAisle aisle: String) -> AsyncStream<[Medicine]>

    /// Server-side filtered stream of medicines whose name starts with `prefix`.
    /// Firestore has no "contains" query, only prefix range queries — this can't match anywhere in the name.
    /// Relies on `Medicine.name` always being stored capitalized (see `MedicineNameFormat`).
    /// That's what lets the match work regardless of how the user typed `prefix`.
    /// No accent normalization — an accepted limitation.
    /// - Parameter prefix: The prefix to match against the start of each medicine's name.
    func observeMedicines(nameStartingWith prefix: String) -> AsyncStream<[Medicine]>

    /// Creates or updates a medicine and returns it with its resolved identifier.
    func save(_ medicine: Medicine) async throws -> Medicine

    /// Permanently removes a medicine. `medicine.id` must be set.
    func delete(_ medicine: Medicine) async throws
}
