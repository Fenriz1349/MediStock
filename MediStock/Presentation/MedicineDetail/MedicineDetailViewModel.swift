//
//  MedicineDetailViewModel.swift
//  MediStock
//
//  Created by Julien Cotte on 04/08/2026.
//

import Foundation

/// Presentation-layer state and actions for viewing a medicine and its history, plus its stock steppers.
/// Name/aisle editing is delegated to `MedicineFormViewModel`, not owned here.
@MainActor
final class MedicineDetailViewModel: ObservableObject {
    @Published private(set) var medicine: Medicine
    @Published private(set) var history: [HistoryEntry] = []
    /// Reset to `nil` at the start of every action, then set again on failure.
    /// The View observes this to trigger a toast, resolving the localized message itself.
    /// This ViewModel never touches the display language.
    @Published private(set) var error: MedicineError?
    /// `true` for the duration of an action, so the View can show a loading indicator.
    @Published private(set) var isLoading = false
    /// `true` once `delete()` has succeeded. The View observes this to dismiss itself.
    @Published private(set) var isDeleted = false

    private let medicineStore: MedicineStoring
    private let historyStore: HistoryStoring
    private let networkMonitor: NetworkMonitoring
    private var historyTask: Task<Void, Never>?

    /// - Parameters:
    ///   - medicine: The medicine to view/edit, injected by the navigation that created this screen.
    ///   - medicineStore: Domain-level abstraction over medicine persistence.
    ///   - historyStore: Domain-level abstraction over history persistence.
    ///   - networkMonitor: Checked before every write. See `verifyNetworkReachable()`.
    init(
        medicine: Medicine,
        medicineStore: MedicineStoring,
        historyStore: HistoryStoring,
        networkMonitor: NetworkMonitoring
    ) {
        self.medicine = medicine
        self.medicineStore = medicineStore
        self.historyStore = historyStore
        self.networkMonitor = networkMonitor
    }

    /// Starts observing this medicine's history. Call once when the screen appears.
    func listen() {
        historyTask?.cancel()
        historyTask = Task { [weak self] in
            guard let medicineId = self?.medicine.id,
                  let stream = self?.historyStore.observeHistory(forMedicineId: medicineId) else { return }
            for await entries in stream {
                self?.history = entries
            }
        }
    }

    /// Replaces `medicine`, e.g. after a successful edit via `MedicineFormViewModel`.
    func applyUpdate(_ updated: Medicine) {
        medicine = updated
    }

    /// Increments the stock by 1.
    func increase() async {
        let previousStock = medicine.stock
        await save(mutate: { $0.stock += 1 },
                  recordHistory: { try await self.historyStore.recordStockChange(of: $0, from: previousStock) })
    }

    /// Decrements the stock by 1.
    func decrease() async {
        let previousStock = medicine.stock
        await save(mutate: { $0.stock -= 1 },
                  recordHistory: { try await self.historyStore.recordStockChange(of: $0, from: previousStock) })
    }

    /// Permanently deletes the medicine. On success, sets `isDeleted` so the View can dismiss.
    func delete() async {
        error = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await verifyNetworkReachable()
            try await medicineStore.delete(medicine)
            try await historyStore.recordDeletion(of: medicine)
        } catch let medicineError as MedicineError {
            error = medicineError
            return
        } catch {
            self.error = .unknown
            return
        }
        isDeleted = true
    }

    /// Applies `mutate` to a copy of the current medicine, persists it.
    /// On success, records the change in the history.
    /// - Parameters:
    ///   - mutate: Applied to a copy of the current `medicine` before it's persisted.
    ///   - recordHistory: Records the change once persistence succeeded.
    ///     So it reflects the actual saved state, e.g. the assigned `id`.
    private func save(mutate: (inout Medicine) -> Void, recordHistory: (Medicine) async throws -> Void) async {
        error = nil
        isLoading = true
        defer { isLoading = false }
        var updated = medicine
        mutate(&updated)
        do {
            try await verifyNetworkReachable()
            medicine = try await medicineStore.save(updated)
        } catch let medicineError as MedicineError {
            error = medicineError
            return
        } catch {
            self.error = .unknown
            return
        }
        do {
            try await recordHistory(medicine)
        } catch let medicineError as MedicineError {
            error = medicineError
        } catch {
            self.error = .unknown
        }
    }

    /// Called before every write, so a lack of connectivity surfaces immediately as a typed error.
    /// - Throws: `MedicineError.network`, wrapping whatever `NetworkError` `networkMonitor` reports.
    private func verifyNetworkReachable() async throws {
        do {
            try await networkMonitor.verifyReachable()
        } catch let networkError as NetworkError {
            throw MedicineError.network(networkError)
        }
    }

    deinit {
        historyTask?.cancel()
    }
}
