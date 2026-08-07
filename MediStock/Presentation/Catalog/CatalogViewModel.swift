//
//  CatalogViewModel.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import Foundation

/// Presentation-layer state and actions for the read-oriented medicine screens (aisles, per-aisle list, full catalog).
/// A single shared instance is injected app-wide so only one subscription to the medicine catalog exists.
@MainActor
final class CatalogViewModel: ObservableObject {
    @Published private(set) var medicines: [Medicine] = []
    /// Reset to `nil` at the start of every action, then set again on failure — the View observes
    /// this to trigger a toast, resolving the localized message itself (this ViewModel never
    /// touches the display language).
    @Published private(set) var error: MedicineError?

    private let medicineStore: MedicineStoring
    private let historyStore: HistoryStoring
    private var observationTask: Task<Void, Never>?

    /// - Parameters:
    ///   - medicineStore: Domain-level abstraction over medicine persistence, kept behind a
    ///     protocol so this ViewModel never depends on Firebase directly.
    ///   - historyStore: Domain-level abstraction over history persistence.
    init(medicineStore: MedicineStoring, historyStore: HistoryStoring) {
        self.medicineStore = medicineStore
        self.historyStore = historyStore
    }

    /// Starts observing the medicine catalog. Call once when the app appears.
    func listen() {
        observationTask?.cancel()
        observationTask = Task { [weak self] in
            guard let stream = self?.medicineStore.observeMedicines() else { return }
            for await medicines in stream {
                self?.medicines = medicines
            }
        }
    }

    /// Distinct aisle codes, derived from the current catalog, sorted the way Finder orders file
    /// names (e.g. "AD2" before "AD10" — a plain string sort would put "AD10" first).
    var aisles: [String] {
        Array(Set(medicines.map(\.aisle))).sorted(by: AisleCode.areInOrder)
    }

    /// Medicines stored in a given aisle.
    /// - Parameter aisle: The exact aisle code to filter on.
    /// - Returns: Every medicine whose `aisle` matches, in catalog order.
    func medicines(inAisle aisle: String) -> [Medicine] {
        medicines.filter { $0.aisle == aisle }
    }

    /// Medicines matching a name filter, sorted per the given option.
    /// - Parameters:
    ///   - filterText: Case-insensitive substring to match against each medicine's name; an empty
    ///     string matches everything.
    ///   - sortOption: How to order the filtered results.
    /// - Returns: The filtered, sorted medicines.
    func medicines(matching filterText: String, sortedBy sortOption: SortOption) -> [Medicine] {
        var result = medicines
        if !filterText.isEmpty {
            result = result.filter { $0.name.lowercased().contains(filterText.lowercased()) }
        }
        switch sortOption {
        case .name:
            result.sort { $0.name.lowercased() < $1.name.lowercased() }
        case .stock:
            result.sort { $0.stock < $1.stock }
        case .none:
            break
        }
        return result
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

    deinit {
        observationTask?.cancel()
    }
}
