//
//  AddMedicineViewModel.swift
//  MediStock
//
//  Created by Julien Cotte on 11/08/2026.
//

import Foundation
import CustomTextFields

/// Presentation-layer state and action for creating a new medicine.
/// Owns its own write — creating a medicine is this screen's own concern, not shared with any other.
/// `nameState`/`aisleState`/`stockState` are written directly by `CustomTextField`.
/// They only drive that field's own border/error display.
/// `isFormValid` does not read them.
/// `CustomTextField`'s "triggered" mode only updates a field's state on losing focus.
/// That never happens for the last field in the form if there's no way to dismiss the keyboard.
/// So `isFormValid` re-checks `MedicinePolicy` directly on the raw text instead.
/// That way the button reflects real validity regardless of which field currently has focus.
@MainActor
final class AddMedicineViewModel: ObservableObject {
    @Published var name = ""
    @Published var aisle = ""
    @Published var stockText = ""
    @Published var nameState: ValidationState = .neutral
    @Published var aisleState: ValidationState = .neutral
    @Published var stockState: ValidationState = .neutral
    /// Reset to `nil` at the start of every action, then set again on failure.
    /// The View observes this to trigger a toast, resolving the localized message itself.
    /// This ViewModel never touches the display language.
    @Published private(set) var error: MedicineError?
    /// `true` for the duration of `save(cleanedAisle:)`, so the View can show a loading indicator.
    @Published private(set) var isLoading = false

    var isFormValid: Bool {
        MedicinePolicy.isValidName(name) && MedicinePolicy.isValidAisle(aisle) && MedicinePolicy.isValidStock(stockText)
    }

    private let medicineStore: MedicineStoring
    private let historyStore: HistoryStoring
    private let networkMonitor: NetworkMonitoring

    /// - Parameters:
    ///   - medicineStore: Domain-level abstraction over medicine persistence.
    ///   - historyStore: Domain-level abstraction over history persistence.
    ///   - networkMonitor: Checked before every write. See `verifyNetworkReachable()`.
    init(medicineStore: MedicineStoring, historyStore: HistoryStoring, networkMonitor: NetworkMonitoring) {
        self.medicineStore = medicineStore
        self.historyStore = historyStore
        self.networkMonitor = networkMonitor
    }

    /// Creates the medicine and records its addition in the history.
    /// - Parameter cleanedAisle: `aisle` already stripped of any redundant localized label.
    ///   That's a display/localization concern the View resolves before calling this.
    ///   This ViewModel doesn't know about it.
    func save(cleanedAisle: String) async {
        error = nil
        isLoading = true
        defer { isLoading = false }
        let medicine = Medicine(name: MedicineNameFormat.capitalized(name), stock: Int(stockText) ?? 0, aisle: cleanedAisle)
        do {
            try await verifyNetworkReachable()
            let saved = try await medicineStore.save(medicine)
            try await historyStore.recordAddition(of: saved)
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
}
