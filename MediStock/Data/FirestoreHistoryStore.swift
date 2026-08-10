//
//  FirestoreHistoryStore.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/// Firestore-backed implementation of `HistoryStoring`, mapping documents to/from `HistoryEntry`.
/// Resolves the acting user itself (via `AuthenticationServicing`) and builds each entry's wording.
/// So callers only ever say *what* happened, never *who* did it or how to phrase it.
final class FirestoreHistoryStore: HistoryStoring {
    private let collection = Firestore.firestore().collection("history")
    private let authenticationService: AuthenticationServicing

    /// - Parameter authenticationService: Domain-level auth abstraction.
    ///   Used only to read the currently signed-in user to attribute each entry to.
    init(authenticationService: AuthenticationServicing) {
        self.authenticationService = authenticationService
    }

    func observeHistory(forMedicineId medicineId: String) -> AsyncStream<[HistoryEntry]> {
        AsyncStream { continuation in
            let listener = collection
                .whereField("medicineId", isEqualTo: medicineId)
                .order(by: "timestamp", descending: true)
                .addSnapshotListener { snapshot, error in
                    guard let snapshot else {
                        if let error { print("Error observing history: \(error)") }
                        return
                    }
                    let entries = snapshot.documents.compactMap { document -> HistoryEntry? in
                        do {
                            return try document.data(as: HistoryEntryDTO.self).toDomain()
                        } catch {
                            // A decode failure used to disappear silently here (try?).
                            // That's exactly how a malformed document could make an entry vanish from the list.
                            // With zero trace of why.
                            print("Error decoding history entry \(document.documentID): \(error)")
                            return nil
                        }
                    }
                    continuation.yield(entries)
                }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    /// - Parameter medicine: The medicine that was just created.
    /// - Throws: `MedicineError`, mapped from whatever Firestore reports.
    func recordAddition(of medicine: Medicine) async throws {
        try await record(action: "Added \(medicine.name)",
                         details: "Added new medicine with initial stock of \(medicine.stock)",
                         medicineId: medicine.id ?? "")
    }

    /// - Parameter medicine: The medicine after the name/aisle update.
    /// - Throws: `MedicineError`, mapped from whatever Firestore reports.
    func recordUpdate(of medicine: Medicine) async throws {
        try await record(action: "Updated \(medicine.name)",
                         details: "Updated medicine details",
                         medicineId: medicine.id ?? "")
    }

    /// - Parameters:
    ///   - medicine: The medicine after the stock change.
    ///   - previousStock: The stock value before the change.
    /// - Throws: `MedicineError`, mapped from whatever Firestore reports.
    func recordStockChange(of medicine: Medicine, from previousStock: Int) async throws {
        let verb = medicine.stock >= previousStock ? "Increased" : "Decreased"
        let delta = abs(medicine.stock - previousStock)
        try await record(action: "\(verb) stock of \(medicine.name) by \(delta)",
                         details: "Stock changed from \(previousStock) to \(medicine.stock)",
                         medicineId: medicine.id ?? "")
    }

    /// - Parameter medicine: The medicine that was just removed from the catalog.
    /// - Throws: `MedicineError`, mapped from whatever Firestore reports.
    func recordDeletion(of medicine: Medicine) async throws {
        try await record(action: "Deleted \(medicine.name)",
                         details: "Removed from catalog with \(medicine.stock) in stock",
                         medicineId: medicine.id ?? "")
    }

    /// Builds and persists the entry shared by every `record...` method above.
    /// - Parameters:
    ///   - action: Short label for the entry (e.g. "Increased stock of X by 1").
    ///   - details: Longer description (e.g. "Stock changed from 9 to 10").
    ///   - medicineId: The medicine the entry is about.
    private func record(action: String, details: String, medicineId: String) async throws {
        let user = authenticationService.currentUser
        let entry = HistoryEntry(medicineId: medicineId,
                                 user: user?.email ?? user?.uid ?? "",
                                 action: action,
                                 details: details)
        let documentRef = collection.document()
        let dto = HistoryEntryDTO(entry: entry)
        do {
            try await documentRef.setData(from: dto)
        } catch {
            throw Self.mapError(error)
        }
    }

    /// Maps a raw error from the Firestore SDK to a Domain-level `MedicineError`, so callers never see a
    /// Firestore type.
    /// - Parameter error: The error thrown by a Firestore SDK call.
    /// - Returns: The corresponding `MedicineError`.
    ///   Or `.unknown` if it isn't one of the specific cases this app handles.
    private static func mapError(_ error: Error) -> MedicineError {
        guard let code = FirestoreErrorCode.Code(rawValue: (error as NSError).code) else { return .unknown }
        switch code {
        case .unavailable:
            return .network(.serverUnreachable)
        case .permissionDenied:
            return .permissionDenied
        default:
            return .unknown
        }
    }
}

/// Firestore document representation of a history entry, carrying the Firestore-specific `@DocumentID`.
private struct HistoryEntryDTO: Codable {
    @DocumentID var id: String?
    var medicineId: String
    var user: String
    var action: String
    var details: String
    var timestamp: Date

    init(entry: HistoryEntry) {
        self.id = entry.id
        self.medicineId = entry.medicineId
        self.user = entry.user
        self.action = entry.action
        self.details = entry.details
        self.timestamp = entry.timestamp
    }

    func toDomain() -> HistoryEntry {
        HistoryEntry(id: id, medicineId: medicineId, user: user, action: action, details: details, timestamp: timestamp)
    }
}
