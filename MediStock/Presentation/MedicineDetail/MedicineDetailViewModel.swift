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

    private let medicineStore: MedicineStoring
    private let historyStore: HistoryStoring
    private let authenticationService: AuthenticationServicing
    private var currentUserId = ""
    private var historyTask: Task<Void, Never>?
    private var sessionTask: Task<Void, Never>?

    init(medicine: Medicine,
         medicineStore: MedicineStoring,
         historyStore: HistoryStoring,
         authenticationService: AuthenticationServicing) {
        self.medicine = medicine
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

    /// Updates the medicine's name and aisle. `aisle` is expected already cleaned of any redundant
    /// label the user may have typed — that's a display/localization concern the View resolves,
    /// this ViewModel doesn't know about it.
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
        do {
            try await medicineStore.delete(medicine)
        } catch {
            print("Error deleting medicine: \(error.localizedDescription)")
        }
    }

    /// Applies `mutate` to a copy of the current medicine, persists it, and on success updates the
    /// local state and records the change in the history. The single save path for every use case
    /// above, so each of them only has to describe *what* changed, not how to persist/log it.
    private func save(action: String, details: String, mutate: (inout Medicine) -> Void) async {
        var updated = medicine
        mutate(&updated)
        do {
            medicine = try await medicineStore.save(updated)
            try await historyStore.record(HistoryEntry(medicineId: medicine.id ?? "",
                                                       user: currentUserId,
                                                       action: action,
                                                       details: details))
        } catch {
            print("Error updating medicine: \(error.localizedDescription)")
        }
    }

    deinit {
        historyTask?.cancel()
        sessionTask?.cancel()
    }
}
