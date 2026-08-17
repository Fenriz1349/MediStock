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
    @Published private(set) var medicines: [Medicine] = []
    @Published var sortOption: SortOption = .none {
        didSet { pageSize = PaginationPolicy.initialPageSize; listen() }
    }
    @Published var sortAscending = true {
        didSet { pageSize = PaginationPolicy.initialPageSize; listen() }
    }
    /// Maximum number of results requested. Raised by `loadMore()`, not a real cursor.
    /// Each raise re-subscribes with a bigger limit rather than fetching only the next page.
    @Published private(set) var pageSize = PaginationPolicy.initialPageSize
    /// Reset to `nil` at the start of every action, then set again on failure.
    /// The View observes this to trigger a toast, resolving the localized message itself.
    /// This ViewModel never touches the display language.
    @Published private(set) var error: MedicineError?
    /// `true` for the duration of a delete, so the View can show a loading indicator.
    @Published private(set) var isLoading = false
    let aisle: String

    private let medicineStore: MedicineStoring
    private let historyStore: HistoryStoring
    private let aisleStore: AisleStoring
    private let networkMonitor: NetworkMonitoring
    private var observationTask: Task<Void, Never>?

    /// - Parameters:
    ///   - aisle: The exact aisle code to observe.
    ///   - medicineStore: Domain-level abstraction over medicine persistence.
    ///   - historyStore: Domain-level abstraction over history persistence.
    ///   - aisleStore: Domain-level abstraction over the aisle-count sync. See `delete(_:)`.
    ///   - networkMonitor: Checked before every delete. See `verifyNetworkReachable()`.
    init(
        aisle: String,
        medicineStore: MedicineStoring,
        historyStore: HistoryStoring,
        aisleStore: AisleStoring,
        networkMonitor: NetworkMonitoring
    ) {
        self.aisle = aisle
        self.medicineStore = medicineStore
        self.historyStore = historyStore
        self.aisleStore = aisleStore
        self.networkMonitor = networkMonitor
    }

    /// Starts observing medicines in this aisle, sorted per `sortOption`/`sortAscending`.
    /// Call once when the screen appears. Automatically re-called whenever any of those change.
    func listen() {
        observationTask?.cancel()
        let sortOption = sortOption
        let sortAscending = sortAscending
        let pageSize = pageSize
        observationTask = Task { [weak self] in
            guard let self else { return }
            let stream = medicineStore.observeMedicines(
                inAisle: aisle,
                sortedBy: sortOption,
                ascending: sortAscending,
                limit: pageSize
            )
            for await medicines in stream {
                self.medicines = medicines
            }
        }
    }

    /// Raises `pageSize` and re-subscribes to load the next batch of results.
    /// Call when the last visible row appears.
    /// No-op if `medicines` came back under `pageSize` — that already was every result there is.
    func loadMore() {
        guard medicines.count >= pageSize else { return }
        pageSize += PaginationPolicy.increment
        listen()
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
            try await aisleStore.recordMedicineRemoved(fromAisle: medicine.aisle)
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
