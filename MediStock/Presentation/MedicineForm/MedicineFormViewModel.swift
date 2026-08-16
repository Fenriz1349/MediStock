//
//  MedicineFormViewModel.swift
//  MediStock
//
//  Created by Julien Cotte on 11/08/2026.
//

import Foundation
import CustomTextFields

/// Presentation-layer state and action for creating or editing a medicine's name/aisle/stock.
/// `existingMedicine` decides the mode — `nil` creates, non-nil updates that medicine.
@MainActor
final class MedicineFormViewModel: ObservableObject {
    let existingMedicine: Medicine?

    @Published var name: String = ""
    @Published var aisle: String = ""
    @Published var stockText: String = ""
    @Published var nameState: ValidationState = .neutral
    @Published var aisleState: ValidationState = .neutral
    @Published var stockState: ValidationState = .neutral
    /// Reset to `nil` at the start of every action, then set again on failure.
    /// The View observes this to trigger a toast, resolving the localized message itself.
    @Published private(set) var error: MedicineError?
    /// `true` for the duration of `save(cleanedAisle:)`, so the View can show a loading indicator.
    @Published private(set) var isLoading = false
    /// Existing aisle codes, for the picker next to the aisle field. See `listenAisles()`.
    @Published private(set) var availableAisles: [String] = []

    /// Stock is only part of the form when creating.
    /// Editing an existing medicine's stock goes through the +/- steppers instead, not this form.
    var isFormValid: Bool {
        guard MedicinePolicy.isValidName(name), MedicinePolicy.isValidAisle(aisle) else { return false }
        return existingMedicine != nil || MedicinePolicy.isValidStock(stockText)
    }

    private let medicineStore: MedicineStoring
    private let historyStore: HistoryStoring
    private let aisleStore: AisleStoring
    private let networkMonitor: NetworkMonitoring
    private var aislesTask: Task<Void, Never>?

    /// - Parameters:
    ///   - existingMedicine: `nil` to create a new medicine, or the medicine being edited.
    ///   - medicineStore: Domain-level abstraction over medicine persistence.
    ///   - historyStore: Domain-level abstraction over history persistence.
    ///   - aisleStore: Domain-level abstraction over the aisle-count sync. See `save(cleanedAisle:)`.
    ///   - networkMonitor: Checked before every write. See `verifyNetworkReachable()`.
    init(
        existingMedicine: Medicine?,
        medicineStore: MedicineStoring,
        historyStore: HistoryStoring,
        aisleStore: AisleStoring,
        networkMonitor: NetworkMonitoring
    ) {
        self.existingMedicine = existingMedicine
        self.medicineStore = medicineStore
        self.historyStore = historyStore
        self.aisleStore = aisleStore
        self.networkMonitor = networkMonitor
        setup()
    }

    /// Pre-fills `name`/`aisle`/`stockText` from `existingMedicine` when editing.
    /// Leaves them blank when creating.
    private func setup() {
        guard let existingMedicine else { return }
        name = existingMedicine.name
        aisle = existingMedicine.aisle
        stockText = String(existingMedicine.stock)
    }

    /// Starts observing existing aisle codes, for the picker. Call once when the screen appears.
    func listenAisles() {
        aislesTask?.cancel()
        aislesTask = Task { [weak self] in
            guard let self else { return }
            for await aisles in aisleStore.observeAisles() {
                self.availableAisles = aisles.map(\.code).sorted(by: AisleCode.areInOrder)
            }
        }
    }

    /// Strips non-digit characters from `stockText`. Call from `.onChange(of: stockText)`.
    func sanitizeStock() {
        let sanitized = MedicinePolicy.sanitizedStock(stockText)
        if sanitized != stockText {
            stockText = sanitized
        }
    }

    /// Strips characters that would break a Firestore document path if used as-is as an `aisles` doc id.
    /// Call from `.onChange(of: aisle)`.
    func sanitizeAisle() {
        let sanitized = MedicinePolicy.sanitizedAisle(aisle)
        if sanitized != aisle {
            aisle = sanitized
        }
    }

    /// Creates or updates the medicine, depending on `existingMedicine`.
    /// - Parameter cleanedAisle: `aisle` already stripped of any redundant localized label.
    ///   That's a display/localization concern the View resolves before calling this.
    /// - Returns: The saved medicine on success, so the caller can refresh its own state. `nil` on failure.
    @discardableResult
    func save(cleanedAisle: String) async -> Medicine? {
        error = nil
        isLoading = true
        defer { isLoading = false }
        var medicine = existingMedicine ?? Medicine(name: "", stock: Int(stockText) ?? 0, aisle: "")
        medicine.name = MedicineNameFormat.capitalized(name)
        medicine.aisle = cleanedAisle
        do {
            try await verifyNetworkReachable()
            let saved = try await medicineStore.save(medicine)
            if let existingMedicine {
                try await historyStore.recordUpdate(of: saved,
                                                    previousName: existingMedicine.name,
                                                    previousAisle: existingMedicine.aisle)
                if existingMedicine.aisle != saved.aisle {
                    try await aisleStore.recordMedicineRemoved(fromAisle: existingMedicine.aisle)
                    try await aisleStore.recordMedicineAdded(toAisle: saved.aisle)
                }
            } else {
                try await historyStore.recordAddition(of: saved)
                try await aisleStore.recordMedicineAdded(toAisle: saved.aisle)
            }
            return saved
        } catch let medicineError as MedicineError {
            error = medicineError
        } catch {
            self.error = .unknown
        }
        return nil
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
        aislesTask?.cancel()
    }
}
