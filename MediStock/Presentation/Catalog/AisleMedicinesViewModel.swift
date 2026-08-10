//
//  AisleMedicinesViewModel.swift
//  MediStock
//
//  Created by Julien Cotte on 10/08/2026.
//

import Foundation

/// Presentation-layer state for the medicines-in-one-aisle screen.
/// Read-only — writes (add/delete) stay on the shared `CatalogViewModel`, which the View still uses for that.
/// Instantiated per screen (scoped to one aisle), unlike the app-wide shared ViewModels.
@MainActor
final class AisleMedicinesViewModel: ObservableObject {
    @Published private(set) var medicines: [Medicine] = []
    let aisle: String

    private let medicineStore: MedicineStoring
    private var observationTask: Task<Void, Never>?

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
                self.medicines = medicines
            }
        }
    }

    deinit {
        observationTask?.cancel()
    }
}
