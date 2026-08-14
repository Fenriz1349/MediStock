//
//  AllMedicinesViewModel.swift
//  MediStock
//
//  Created by Julien Cotte on 10/08/2026.
//

import Foundation

/// Presentation-layer state for the full-catalog screen.
/// While `filterText` is non-empty, sorting doesn't apply.
/// A name-prefix search only ever returns a small, already name-ordered result set.
@MainActor
final class AllMedicinesViewModel: ObservableObject {
    @Published private(set) var medicines: [Medicine] = []
    @Published var sortOption: SortOption = .none {
        didSet { pageSize = PaginationPolicy.initialPageSize; listen() }
    }
    /// The sort direction. Ignored when `sortOption` is `.none`.
    @Published var sortAscending = true {
        didSet { pageSize = PaginationPolicy.initialPageSize; listen() }
    }
    /// Firestore prefix match on the medicine name.
    /// Doesn't match anywhere else in the name — only the start.
    @Published var filterText = "" {
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
    /// `sortOption`, `sortAscending` and `pageSize`.
    /// Call once when the screen appears.
    /// Automatically re-called whenever any of those change.
    func listen() {
        observationTask?.cancel()
        let sortOption = sortOption
        let sortAscending = sortAscending
        let filterText = filterText
        let pageSize = pageSize
        observationTask = Task { [weak self] in
            guard let self else { return }
            if filterText.isEmpty {
                let stream = medicineStore.observeMedicines(
                    sortedBy: sortOption,
                    ascending: sortAscending,
                    limit: pageSize
                )
                for await medicines in stream {
                    self.medicines = medicines
                }
            } else {
                // Already returned name-ordered by Firestore — no sort to apply here.
                let stream = medicineStore.observeMedicines(nameStartingWith: filterText, limit: pageSize)
                for await medicines in stream {
                    self.medicines = medicines
                }
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
