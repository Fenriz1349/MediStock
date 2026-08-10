//
//  AllMedicinesViewModel.swift
//  MediStock
//
//  Created by Julien Cotte on 10/08/2026.
//

import Foundation

/// Presentation-layer state for the full-catalog screen.
/// Sorting happens server-side (re-queries Firestore whenever `sortOption` changes).
/// Name search stays local, applied on top of the already-loaded, already-sorted list.
/// Firestore has no "contains" query.
/// Re-querying on every keystroke would also waste reads for no benefit, since the data is already loaded.
@MainActor
final class AllMedicinesViewModel: ObservableObject {
    @Published private(set) var medicines: [Medicine] = []
    @Published var sortOption: SortOption = .none {
        didSet { listen() }
    }

    private let medicineStore: MedicineStoring
    private var observationTask: Task<Void, Never>?

    /// - Parameter medicineStore: Domain-level abstraction over medicine persistence.
    init(medicineStore: MedicineStoring) {
        self.medicineStore = medicineStore
    }

    /// Starts observing the medicine catalog, sorted per the current `sortOption`.
    /// Call once when the screen appears; automatically re-called whenever `sortOption` changes.
    func listen() {
        observationTask?.cancel()
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await medicines in medicineStore.observeMedicines(sortedBy: sortOption) {
                self.medicines = medicines
            }
        }
    }

    /// Medicines whose name contains `filterText`.
    /// Applied locally over the current (already server-sorted) list.
    /// Kept local specifically so it can match anywhere in the name, not just a prefix.
    /// A Firestore-side query could only do "starts with".
    /// - Parameter filterText: Case-insensitive substring to match against each medicine's name.
    ///   An empty string matches everything.
    /// - Returns: The filtered medicines, in their current server-sorted order.
    func medicines(matching filterText: String) -> [Medicine] {
        guard !filterText.isEmpty else { return medicines }
        return medicines.filter { $0.name.lowercased().contains(filterText.lowercased()) }
    }

    deinit {
        observationTask?.cancel()
    }
}
