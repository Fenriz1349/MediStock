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

    private let medicineStore: MedicineStoring
    private let historyStore: HistoryStoring
    private var observationTask: Task<Void, Never>?

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

    /// Distinct aisle names, derived from the current catalog.
    var aisles: [String] {
        Array(Set(medicines.map(\.aisle))).sorted()
    }

    /// Medicines stored in a given aisle.
    func medicines(inAisle aisle: String) -> [Medicine] {
        medicines.filter { $0.aisle == aisle }
    }

    /// Medicines matching a name filter, sorted per the given option.
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

    func addMedicine(name: String, stock: Int, aisle: String, user: String) async {
        let medicine = Medicine(name: name, stock: stock, aisle: aisle)
        do {
            let saved = try await medicineStore.save(medicine)
            try await historyStore.record(HistoryEntry(medicineId: saved.id ?? "", user: user, action: "Added \(saved.name)", details: "Added new medicine"))
        } catch {
            print("Error adding medicine: \(error.localizedDescription)")
        }
    }

    func delete(_ medicine: Medicine) async {
        do {
            try await medicineStore.delete(medicine)
        } catch {
            print("Error deleting medicine: \(error.localizedDescription)")
        }
    }

    deinit {
        observationTask?.cancel()
    }
}
