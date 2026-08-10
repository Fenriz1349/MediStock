//
//  CatalogViewModel.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import Foundation

/// Presentation-layer write access to the medicine catalog (add/delete), shared app-wide.
/// Reading the catalog is each screen's own concern now (`AllMedicinesViewModel`, `AisleListViewModel`,
/// `AisleMedicinesViewModel`), each with its own server-side query.
/// This ViewModel only covers what's genuinely identical regardless of which screen triggers it.
@MainActor
final class CatalogViewModel: ObservableObject {
    /// Reset to `nil` at the start of every action, then set again on failure.
    /// The View observes this to trigger a toast, resolving the localized message itself.
    /// This ViewModel never touches the display language.
    @Published private(set) var error: MedicineError?

    private let medicineStore: MedicineStoring
    private let historyStore: HistoryStoring

    /// - Parameters:
    ///   - medicineStore: Domain-level abstraction over medicine persistence, kept behind a protocol.
    ///     This ViewModel never depends on Firebase directly.
    ///   - historyStore: Domain-level abstraction over history persistence.
    init(medicineStore: MedicineStoring, historyStore: HistoryStoring) {
        self.medicineStore = medicineStore
        self.historyStore = historyStore
    }

    /// Creates a new medicine and records its addition in the history.
    /// - Parameters:
    ///   - name: The medicine's display name.
    ///   - stock: The initial quantity in stock.
    ///   - aisle: The aisle code, already cleaned of any redundant localized label by the caller.
    func addMedicine(name: String, stock: Int, aisle: String) async {
        error = nil
        let medicine = Medicine(name: name, stock: stock, aisle: aisle)
        do {
            let saved = try await medicineStore.save(medicine)
            try await historyStore.recordAddition(of: saved)
        } catch let medicineError as MedicineError {
            error = medicineError
        } catch {
            self.error = .unknown
        }
    }

    /// Removes a medicine from the catalog and records the deletion in the history.
    /// - Parameter medicine: The medicine to delete.
    func delete(_ medicine: Medicine) async {
        error = nil
        do {
            try await medicineStore.delete(medicine)
            try await historyStore.recordDeletion(of: medicine)
        } catch let medicineError as MedicineError {
            error = medicineError
        } catch {
            self.error = .unknown
        }
    }
}
