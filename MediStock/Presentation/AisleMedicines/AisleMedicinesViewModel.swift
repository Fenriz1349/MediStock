//
//  AisleMedicinesViewModel.swift
//  MediStock
//
//  Created by Julien Cotte on 10/08/2026.
//

import Foundation

/// Presentation-layer state for the medicines-in-one-aisle screen. Read-only — no delete, no admin role yet.
/// Instantiated per screen (scoped to one aisle), unlike the app-wide shared ViewModels.
@MainActor
final class AisleMedicinesViewModel: ObservableObject {
    @Published private(set) var allMedicines: [Medicine] = []
    @Published var sortOption: SortOption = .none
    @Published var sortAscending = true
    let aisle: String

    private let medicineStore: MedicineStoring
    private var observationTask: Task<Void, Never>?

    /// `allMedicines`, sorted per `sortOption`/`sortAscending`.
    /// Purely local — the aisle's medicines are already fully loaded, no query to re-issue.
    var medicines: [Medicine] {
        switch sortOption {
        case .none:
            allMedicines
        case .name:
            allMedicines.sorted { sortAscending ? $0.name < $1.name : $0.name > $1.name }
        case .stock:
            allMedicines.sorted { sortAscending ? $0.stock < $1.stock : $0.stock > $1.stock }
        }
    }

    /// - Parameters:
    ///   - aisle: The exact aisle code to observe.
    ///   - medicineStore: Domain-level abstraction over medicine persistence.
    init(aisle: String, medicineStore: MedicineStoring) {
        self.aisle = aisle
        self.medicineStore = medicineStore
    }

    /// Starts observing medicines in this aisle. Call once when the screen appears.
    func listen() {
        observationTask?.cancel()
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await medicines in medicineStore.observeMedicines(inAisle: aisle) {
                self.allMedicines = medicines
            }
        }
    }

    deinit {
        observationTask?.cancel()
    }
}
