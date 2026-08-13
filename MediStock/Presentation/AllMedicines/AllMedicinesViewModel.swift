//
//  AllMedicinesViewModel.swift
//  MediStock
//
//  Created by Julien Cotte on 10/08/2026.
//

import Foundation

/// Presentation-layer state for the full-catalog screen.
/// Sorting and name search both happen server-side.
/// While `filterText` is non-empty, the query switches to a Firestore prefix match on the name.
/// `sortOption`/`sortAscending` are then applied locally, on that already filtered (so small) result set.
/// Firestore requires the first `.order(by:)` to be on the same field as a range filter.
/// So the name-prefix query and an arbitrary sort field can't both run server-side at once.
@MainActor
final class AllMedicinesViewModel: ObservableObject {
    @Published private(set) var medicines: [Medicine] = []
    @Published var sortOption: SortOption = .none {
        didSet { listen() }
    }
    /// The sort direction. Ignored when `sortOption` is `.none`.
    @Published var sortAscending = true {
        didSet { listen() }
    }
    /// Firestore prefix match on the medicine name.
    /// Doesn't match anywhere else in the name — only the start.
    @Published var filterText = "" {
        didSet { listen() }
    }

    private let medicineStore: MedicineStoring
    private var observationTask: Task<Void, Never>?

    /// - Parameter medicineStore: Domain-level abstraction over medicine persistence.
    init(medicineStore: MedicineStoring) {
        self.medicineStore = medicineStore
    }

    /// Starts observing the medicine catalog, filtered/sorted per the current `filterText`,
    /// `sortOption` and `sortAscending`.
    /// Call once when the screen appears.
    /// Automatically re-called whenever any of those three change.
    func listen() {
        observationTask?.cancel()
        let sortOption = sortOption
        let sortAscending = sortAscending
        let filterText = filterText
        observationTask = Task { [weak self] in
            guard let self else { return }
            if filterText.isEmpty {
                for await medicines in medicineStore.observeMedicines(sortedBy: sortOption, ascending: sortAscending) {
                    self.medicines = medicines
                }
            } else {
                for await medicines in medicineStore.observeMedicines(nameStartingWith: filterText) {
                    self.medicines = Self.sort(medicines, by: sortOption, ascending: sortAscending)
                }
            }
        }
    }

    /// Applies `sortOption`/`sortAscending` locally, used only for the already name-filtered result set.
    private static func sort(_ medicines: [Medicine], by sortOption: SortOption, ascending: Bool) -> [Medicine] {
        switch sortOption {
        case .none:
            medicines
        case .name:
            medicines.sorted { ascending ? $0.name < $1.name : $0.name > $1.name }
        case .stock:
            medicines.sorted { ascending ? $0.stock < $1.stock : $0.stock > $1.stock }
        }
    }

    deinit {
        observationTask?.cancel()
    }
}
