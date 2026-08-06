//
//  MedicineDetailViewModel.swift
//  MediStock
//
//  Created by Julien Cotte on 04/08/2026.
//

import Foundation

/// Presentation-layer state and actions for viewing/editing a single medicine and its history.
/// Instantiated per detail screen (scoped to one medicine), unlike the app-wide shared ViewModels.
@MainActor
final class MedicineDetailViewModel: ObservableObject {
    @Published private(set) var history: [HistoryEntry] = []

    private let medicineStore: MedicineStoring
    private let historyStore: HistoryStoring
    private var observationTask: Task<Void, Never>?

    init(medicineStore: MedicineStoring, historyStore: HistoryStoring) {
        self.medicineStore = medicineStore
        self.historyStore = historyStore
    }

    /// Starts observing this medicine's history. Call once when the screen appears.
    func listen(forMedicineId medicineId: String) {
        observationTask?.cancel()
        observationTask = Task { [weak self] in
            guard let stream = self?.historyStore.observeHistory(forMedicineId: medicineId) else { return }
            for await entries in stream {
                self?.history = entries
            }
        }
    }

    func updateMedicine(_ medicine: Medicine, user: String) async {
        do {
            _ = try await medicineStore.save(medicine)
            try await recordHistory(action: "Updated \(medicine.name)", details: "Updated medicine details", medicineId: medicine.id, user: user)
        } catch {
            print("Error updating medicine: \(error.localizedDescription)")
        }
    }

    func increaseStock(_ medicine: Medicine, user: String) async {
        await updateStock(medicine, by: 1, user: user)
    }

    func decreaseStock(_ medicine: Medicine, user: String) async {
        await updateStock(medicine, by: -1, user: user)
    }

    private func updateStock(_ medicine: Medicine, by amount: Int, user: String) async {
        var updated = medicine
        updated.stock += amount
        do {
            _ = try await medicineStore.save(updated)
            try await recordHistory(
                action: "\(amount > 0 ? "Increased" : "Decreased") stock of \(medicine.name) by \(amount)",
                details: "Stock changed from \(medicine.stock) to \(updated.stock)",
                medicineId: medicine.id,
                user: user
            )
        } catch {
            print("Error updating stock: \(error.localizedDescription)")
        }
    }

    private func recordHistory(action: String, details: String, medicineId: String?, user: String) async throws {
        try await historyStore.record(HistoryEntry(medicineId: medicineId ?? "", user: user, action: action, details: details))
    }

    deinit {
        observationTask?.cancel()
    }
}
