//
//  MedicineDetailViewModel.swift
//  MediStock
//
//  Created by Julien Cotte on 04/08/2026.
//

import Foundation

/// Presentation-layer state and actions for viewing/editing a single medicine and its history.
/// Owns the medicine being viewed and depends only on Domain protocols (no other ViewModel).
/// So the screen that hosts it needs nothing but this ViewModel.
/// Instantiated per detail screen (scoped to one medicine), unlike the app-wide shared ViewModels.
/// Never knows who the current user is — `HistoryStoring` resolves that itself when it records an entry.
@MainActor
final class MedicineDetailViewModel: ObservableObject {
    @Published private(set) var medicine: Medicine
    @Published private(set) var history: [HistoryEntry] = []
    @Published var name: String
    @Published var aisle: String
    /// Reset to `nil` at the start of every action, then set again on failure.
    /// The View observes this to trigger a toast, resolving the localized message itself.
    /// This ViewModel never touches the display language.
    @Published private(set) var error: MedicineError?

    private let medicineStore: MedicineStoring
    private let historyStore: HistoryStoring
    private var historyTask: Task<Void, Never>?
    private var saveLabelTask: Task<Void, Never>?

    /// - Parameters:
    ///   - medicine: The medicine to view/edit, injected by the navigation that created this screen.
    ///   - medicineStore: Domain-level abstraction over medicine persistence.
    ///   - historyStore: Domain-level abstraction over history persistence.
    init(medicine: Medicine, medicineStore: MedicineStoring, historyStore: HistoryStoring) {
        self.medicine = medicine
        self.name = medicine.name
        self.aisle = medicine.aisle
        self.medicineStore = medicineStore
        self.historyStore = historyStore
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

    /// Called by the View whenever `name`/`aisle` change.
    /// `cleanedAisle` is `aisle` already stripped of any redundant label the user may have typed.
    /// That's a display/localization concern the View resolves before calling this.
    /// This ViewModel doesn't know about it.
    /// Cancels any save still in flight from a previous keystroke before starting this one.
    /// So rapid typing can't fire overlapping saves that race and land out of order.
    /// - Parameter cleanedAisle: `aisle` already stripped of any redundant localized label.
    func scheduleLabelSave(cleanedAisle: String) {
        saveLabelTask?.cancel()
        saveLabelTask = Task { [weak self] in
            await self?.saveLabelIfNeeded(cleanedAisle: cleanedAisle)
        }
    }

    /// Skips the save if nothing actually changed vs. the persisted `medicine`.
    /// Avoids re-saving on the initial assignment of `name`/`aisle` from `medicine` in `init`.
    private func saveLabelIfNeeded(cleanedAisle: String) async {
        guard name != medicine.name || cleanedAisle != medicine.aisle else { return }
        await updateLabel(name: name, aisle: cleanedAisle)
    }

    /// Updates the medicine's name and aisle.
    /// `aisle` is expected already cleaned of any redundant label the user may have typed.
    /// That's a display/localization concern the View resolves — this ViewModel doesn't know about it.
    /// - Parameters:
    ///   - name: The new display name.
    ///   - aisle: The new aisle code, already cleaned of any redundant localized label.
    func updateLabel(name: String, aisle: String) async {
        await save(mutate: {
            $0.name = name
            $0.aisle = aisle
        }, recordHistory: { try await self.historyStore.recordUpdate(of: $0) })
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

    /// Removes the medicine from the catalog and records the deletion in the history.
    func delete() async {
        error = nil
        do {
            try await medicineStore.delete(medicine)
            try await historyStore.recordDeletion(of: medicine)
        } catch let medicineError as MedicineError {
            error = medicineError
        } catch {
            self.error = .unknown
        }
    }

    /// Applies `mutate` to a copy of the current medicine, persists it.
    /// On success, records the change in the history.
    /// The single save path for every use case above.
    /// So each of them only has to describe *what* changed, not how to persist/log it.
    /// - Parameters:
    ///   - mutate: Applied to a copy of the current `medicine` before it's persisted.
    ///   - recordHistory: Records the change once persistence succeeded.
    ///     So it reflects the actual saved state, e.g. the assigned `id`.
    private func save(mutate: (inout Medicine) -> Void, recordHistory: (Medicine) async throws -> Void) async {
        error = nil
        var updated = medicine
        mutate(&updated)
        do {
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

    deinit {
        historyTask?.cancel()
        saveLabelTask?.cancel()
    }
}
