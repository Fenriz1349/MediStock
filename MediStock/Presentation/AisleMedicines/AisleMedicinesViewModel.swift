//
//  AisleMedicinesViewModel.swift
//  MediStock
//
//  Created by Julien Cotte on 10/08/2026.
//

import Foundation

/// Presentation-layer state for the medicines-in-one-aisle screen.
/// Instantiated per screen (scoped to one aisle), unlike the app-wide shared ViewModels.
@MainActor
final class AisleMedicinesViewModel: ObservableObject {
    @Published private(set) var allMedicines: [Medicine] = []
    @Published var sortOption: SortOption = .none
    @Published var sortAscending = true
    /// Reset to `nil` at the start of every action, then set again on failure.
    /// The View observes this to trigger a toast, resolving the localized message itself.
    /// This ViewModel never touches the display language.
    @Published private(set) var error: MedicineError?
    /// `true` for the duration of a delete, so the View can show a loading indicator.
    @Published private(set) var isLoading = false
    let aisle: String

    private let medicineStore: MedicineStoring
    private let historyStore: HistoryStoring
    private let networkMonitor: NetworkMonitoring
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
    ///   - historyStore: Domain-level abstraction over history persistence.
    ///   - networkMonitor: Checked before every delete. See `verifyNetworkReachable()`.
    init(
        aisle: String,
        medicineStore: MedicineStoring,
        historyStore: HistoryStoring,
        networkMonitor: NetworkMonitoring
    ) {
        self.aisle = aisle
        self.medicineStore = medicineStore
        self.historyStore = historyStore
        self.networkMonitor = networkMonitor
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

    deinit {
        observationTask?.cancel()
    }
}
