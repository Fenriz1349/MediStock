//
//  MedicineStoring.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import Foundation

/// Read/write access to the medicine catalog, with live updates as the underlying data changes.
protocol MedicineStoring {
    /// An ongoing stream of the current medicine list, emitting a new snapshot on every change.
    func observeMedicines() -> AsyncStream<[Medicine]>

    /// Creates or updates a medicine and returns it with its resolved identifier.
    func save(_ medicine: Medicine) async throws -> Medicine

    /// Removes a medicine from the catalog.
    func delete(_ medicine: Medicine) async throws
}
