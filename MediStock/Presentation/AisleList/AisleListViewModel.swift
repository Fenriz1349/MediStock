//
//  AisleListViewModel.swift
//  MediStock
//
//  Created by Julien Cotte on 10/08/2026.
//

import Foundation

/// Presentation-layer state for the aisle list screen.
/// Reads the `aisles` collection directly (see `AisleStoring`) instead of deriving from every medicine.
@MainActor
final class AisleListViewModel: ObservableObject {
    @Published private(set) var allAisles: [String] = []
    private var medicineCounts: [String: Int] = [:]
    /// The sort direction applied to `aisles`.
    @Published var sortAscending = true
    /// Case-insensitive substring to match against each aisle code.
    /// An empty string matches everything.
    /// Purely local, same reasoning as `sortAscending` — all the data is already loaded.
    @Published var filterText = ""

    private let aisleStore: AisleStoring
    private var observationTask: Task<Void, Never>?

    /// - Parameter aisleStore: Domain-level abstraction over the `aisles` collection.
    init(aisleStore: AisleStoring) {
        self.aisleStore = aisleStore
    }

    /// Starts observing the `aisles` collection.
    /// Sorted the way Finder orders file names (e.g. "AD2" before "AD10" — a plain string sort would put
    /// "AD10" first).
    /// Call once when the screen appears.
    func listen() {
        observationTask?.cancel()
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await aisles in aisleStore.observeAisles() {
                self.allAisles = aisles.map(\.code).sorted(by: AisleCode.areInOrder)
                self.medicineCounts = Dictionary(uniqueKeysWithValues: aisles.map { ($0.code, $0.medicineCount) })
            }
        }
    }

    /// The number of medicines in `aisle`, `0` if it isn't currently in `allAisles`.
    func medicineCount(forAisle aisle: String) -> Int {
        medicineCounts[aisle] ?? 0
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
