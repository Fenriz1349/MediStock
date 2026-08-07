//
//  MedicineDetailViewModel.swift
//  MediStock
//
//  Created by Julien Cotte on 04/08/2026.
//

import Foundation

/// Presentation-layer state and actions for viewing/editing a single medicine and its history.
/// Owns the medicine being viewed and depends only on Domain protocols (no other ViewModel),
/// so the screen that hosts it needs nothing but this ViewModel. Instantiated per detail screen
/// (scoped to one medicine), unlike the app-wide shared ViewModels.
@MainActor
final class MedicineDetailViewModel: ObservableObject {
    @Published private(set) var medicine: Medicine
    @Published private(set) var history: [HistoryEntry] = []
    @Published var name: String
    @Published var aisle: String
    /// Reset to `nil` at the start of every action, then set again on failure — the View observes
    /// this to trigger a toast, resolving the localized message itself (this ViewModel never
    /// touches the display language).
    @Published private(set) var error: MedicineError?

    private let medicineStore: MedicineStoring
    private let historyStore: HistoryStoring
    private let authenticationService: AuthenticationServicing
    private var currentUserId = ""
    private var historyTask: Task<Void, Never>?
    private var sessionTask: Task<Void, Never>?
    private var saveLabelTask: Task<Void, Never>?

    /// - Parameters:
    ///   - medicine: The medicine to view/edit, injected by the navigation that created this screen.
    ///   - medicineStore: Domain-level abstraction over medicine persistence.
    ///   - historyStore: Domain-level abstraction over history persistence.
    ///   - authenticationService: Domain-level auth abstraction, used only to read the current
    ///     user's id for history entries — this ViewModel never touches sign-in/out itself.
    init(medicine: Medicine,
         medicineStore: MedicineStoring,
         historyStore: HistoryStoring,
         authenticationService: AuthenticationServicing) {
        self.medicine = medicine
        self.name = medicine.name
        self.aisle = medicine.aisle
        self.medicineStore = medicineStore
        self.historyStore = historyStore
        self.authenticationService = authenticationService
    }

    /// Starts observing this medicine's history and the current user session. Call once when the
    /// screen appears.
    func listen() {
        historyTask?.cancel()
        historyTask = Task { [weak self] in
            guard let medicineId = self?.medicine.id,
                  let stream = self?.historyStore.observeHistory(forMedicineId: medicineId) else { return }
            for await entries in stream {
                self?.history = entries
            }
        }
        sessionTask?.cancel()
        sessionTask = Task { [weak self] in
            guard let stream = self?.authenticationService.observeSession() else { return }
            for await user in stream {
                self?.currentUserId = user?.uid ?? ""
            }
        }
    }

    /// Called by the View whenever `name`/`aisle` change. `cleanedAisle` is `aisle` already
    /// stripped of any redundant label the user may have typed — that's a display/localization
    /// concern the View resolves before calling this, this ViewModel doesn't know about it.
    /// Cancels any save still in flight from a previous keystroke before starting this one, so
    /// rapid typing can't fire overlapping saves that race and land out of order.
    /// - Parameter cleanedAisle: `aisle` already stripped of any redundant localized label.
    func scheduleLabelSave(cleanedAisle: String) {
        saveLabelTask?.cancel()
        saveLabelTask = Task { [weak self] in
            await self?.saveLabelIfNeeded(cleanedAisle: cleanedAisle)
        }
    }

    /// Skips the save if nothing actually changed vs. the persisted `medicine` (avoids re-saving
    /// on the initial assignment of `name`/`aisle` from `medicine` in `init`).
    private func saveLabelIfNeeded(cleanedAisle: String) async {
        guard name != medicine.name || cleanedAisle != medicine.aisle else { return }
        await updateLabel(name: name, aisle: cleanedAisle)
    }

    /// Updates the medicine's name and aisle. `aisle` is expected already cleaned of any redundant
    /// label the user may have typed — that's a display/localization concern the View resolves,
    /// this ViewModel doesn't know about it.
    /// - Parameters:
    ///   - name: The new display name.
    ///   - aisle: The new aisle code, already cleaned of any redundant localized label.
    func updateLabel(name: String, aisle: String) async {
        await save(action: "Updated \(name)", details: "Updated medicine details") {
            $0.name = name
            $0.aisle = aisle
        }
    }

    /// Increments the stock by 1.
    func increase() async {
        let newStock = medicine.stock + 1
        await save(
            action: "Increased stock of \(medicine.name) by 1",
            details: "Stock changed from \(medicine.stock) to \(newStock)"
        ) { $0.stock = newStock }
    }

    /// Decrements the stock by 1.
    func decrease() async {
        let newStock = medicine.stock - 1
        await save(
            action: "Decreased stock of \(medicine.name) by 1",
            details: "Stock changed from \(medicine.stock) to \(newStock)"
        ) { $0.stock = newStock }
    }

    /// Removes the medicine from the catalog. No history entry recorded yet — deliberately
    /// deferred to `refactor/history-reliability`, which centralizes all history writing.
    func delete() async {
        error = nil
        do {
            try await medicineStore.delete(medicine)
        } catch let medicineError as MedicineError {
            error = medicineError
        } catch {
            self.error = .unknown
        }
    }

    /// Applies `mutate` to a copy of the current medicine, persists it, and on success updates the
    /// local state and records the change in the history. The single save path for every use case
    /// above, so each of them only has to describe *what* changed, not how to persist/log it.
    /// - Parameters:
    ///   - action: Short label for the history entry (e.g. "Increased stock of X by 1").
    ///   - details: Longer description for the history entry (e.g. "Stock changed from 9 to 10").
    ///   - mutate: Applied to a copy of the current `medicine` before it's persisted.
    private func save(action: String, details: String, mutate: (inout Medicine) -> Void) async {
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
            try await historyStore.record(HistoryEntry(medicineId: medicine.id ?? "",
                                                       user: currentUserId,
                                                       action: action,
                                                       details: details))
        } catch let medicineError as MedicineError {
            error = medicineError
        } catch {
            self.error = .unknown
        }
    }

    deinit {
        historyTask?.cancel()
        sessionTask?.cancel()
        saveLabelTask?.cancel()
    }
}
