//
//  AisleListViewModel.swift
//  MediStock
//
//  Created by Julien Cotte on 10/08/2026.
//

import Foundation

/// Presentation-layer state for the aisle list screen. Derives the distinct aisle codes from the full medicine stream.
/// Firestore has no "distinct"/"group by" query.
/// So this can't be pushed server-side like the other screens' queries (see `AisleMedicinesViewModel`).
@MainActor
final class AisleListViewModel: ObservableObject {
    @Published private(set) var allAisles: [String] = []
    /// The sort direction applied to `aisles`.
    @Published var sortAscending = true
    /// Case-insensitive substring to match against each aisle code.
    /// An empty string matches everything.
    /// Purely local, same reasoning as `sortAscending` — all the data is already loaded.
    @Published var filterText = ""

    private let medicineStore: MedicineStoring
    private var observationTask: Task<Void, Never>?

    /// - Parameter medicineStore: Domain-level abstraction over medicine persistence.
    init(medicineStore: MedicineStoring) {
        self.medicineStore = medicineStore
    }

    /// Starts observing the medicine catalog to derive its distinct aisles.
    /// Sorted the way Finder orders file names (e.g. "AD2" before "AD10" — a plain string sort would put
    /// "AD10" first).
    /// Call once when the screen appears.
    func listen() {
        observationTask?.cancel()
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await medicines in medicineStore.observeMedicines() {
                self.allAisles = Array(Set(medicines.map(\.aisle))).sorted(by: AisleCode.areInOrder)
            }
        }
    }

    /// `allAisles`, filtered by `filterText` and ordered per `sortAscending`.
    /// Purely local — the underlying data is already fully loaded, no query to re-issue.
    var aisles: [String] {
        let filtered = filterText.isEmpty
            ? allAisles
            : allAisles.filter { $0.localizedCaseInsensitiveContains(filterText) }
        return sortAscending ? filtered : filtered.reversed()
    }

    deinit {
        observationTask?.cancel()
    }
}
