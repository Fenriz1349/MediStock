//
//  MedicineStoring.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import Foundation

/// Read/write access to the medicine catalog, with live updates as the underlying data changes.
/// One method per real query need — filtering/sorting happens server-side wherever Firestore can
/// express it, rather than fetching everything and filtering in memory.
protocol MedicineStoring {
    /// The full, unfiltered stream of the current medicine list. Used only where Firestore can't
    /// express the need as a query directly (e.g. deriving the distinct list of aisles — Firestore
    /// has no "distinct"/"group by" query, so that still has to happen in memory).
    func observeMedicines() -> AsyncStream<[Medicine]>

    /// Server-side filtered and sorted stream.
    /// - Parameters:
    ///   - filterText: Matches medicines whose name *starts with* this text (case handling is the
    ///     implementation's concern) — Firestore has no "contains" query, only range queries, which
    ///     only support a prefix match. An empty string matches everything.
    ///   - sortOption: How to order the results.
    func observeMedicines(matching filterText: String, sortedBy sortOption: SortOption) -> AsyncStream<[Medicine]>

    /// Server-side filtered stream of medicines in a given aisle.
    /// - Parameter aisle: The exact aisle code to filter on.
    func observeMedicines(inAisle aisle: String) -> AsyncStream<[Medicine]>

    /// Creates or updates a medicine and returns it with its resolved identifier.
    func save(_ medicine: Medicine) async throws -> Medicine

    /// Removes a medicine from the catalog.
    func delete(_ medicine: Medicine) async throws
}
