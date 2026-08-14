//
//  AllMedicinesViewModel.swift
//  MediStock
//
//  Created by Julien Cotte on 10/08/2026.
//

import Foundation

/// Presentation-layer state for the full-catalog screen.
/// While `filterText` is non-empty, search runs server-side and sort is applied locally on that result.
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
    /// Reset to `nil` at the start of every action, then set again on failure.
    /// The View observes this to trigger a toast, resolving the localized message itself.
    /// This ViewModel never touches the display language.
    @Published private(set) var error: MedicineError?
    /// `true` for the duration of a delete, so the View can show a loading indicator.
    @Published private(set) var isLoading = false

    private let medicineStore: MedicineStoring
    private let historyStore: HistoryStoring
    private let networkMonitor: NetworkMonitoring
    private var observationTask: Task<Void, Never>?

    /// - Parameters:
    ///   - medicineStore: Domain-level abstraction over medicine persistence.
    ///   - historyStore: Domain-level abstraction over history persistence.
    ///   - networkMonitor: Checked before every delete. See `verifyNetworkReachable()`.
    init(medicineStore: MedicineStoring, historyStore: HistoryStoring, networkMonitor: NetworkMonitoring) {
        self.medicineStore = medicineStore
        self.historyStore = historyStore
        self.networkMonitor = networkMonitor
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

    /// Permanently deletes `medicine`.
    func delete(_ medicine: Medicine) async {
        error = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await verifyNetworkReachable()
            try await medicineStore.delete(medicine)
            try await historyStore.recordDeletion(of: medicine)
        } catch let medicineError as MedicineError {
            error = medicineError
        } catch {
            self.error = .unknown
        }
    }

    /// Called before every delete, so a lack of connectivity surfaces immediately as a typed error.
    /// - Throws: `MedicineError.network`, wrapping whatever `NetworkError` `networkMonitor` reports.
    private func verifyNetworkReachable() async throws {
        do {
            try await networkMonitor.verifyReachable()
        } catch let networkError as NetworkError {
            throw MedicineError.network(networkError)
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
