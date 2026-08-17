//
//  FirestoreAisleStore.swift
//  MediStock
//
//  Created by Julien Cotte on 16/08/2026.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/// Firestore-backed implementation of `AisleStoring`.
/// Syncs a lightweight per-aisle count document whenever `medicines` writes add or remove a medicine.
final class FirestoreAisleStore: AisleStoring {
    private let collection = Firestore.firestore().collection("aisles")

    /// Only aisles that still have at least one medicine.
    /// A doc that reaches 0 is never deleted, just filtered out here.
    /// Accepted tradeoff: avoids a transaction, at the cost of harmless zero-count documents.
    /// E.g. left behind in Firestore after a typo'd aisle code gets corrected.
    func observeAisles() -> AsyncStream<[AisleSummary]> {
        AsyncStream { continuation in
            let listener = collection
                .whereField("medicineCount", isGreaterThan: 0)
                .addSnapshotListener { snapshot, error in
                    guard let snapshot else {
                        if let error { print("Error observing aisles: \(error)") }
                        return
                    }
                    let aisles = snapshot.documents.compactMap { try? $0.data(as: AisleSummaryDTO.self).toDomain() }
                    continuation.yield(aisles)
                }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    /// - Parameter aisle: The aisle a medicine was just created in, or moved into.
    /// - Throws: `MedicineError`, mapped from whatever Firestore reports.
    func recordMedicineAdded(toAisle aisle: String) async throws {
        try await adjustCount(forAisle: aisle, by: 1)
    }

    /// - Parameter aisle: The aisle a medicine was just deleted from, or moved out of.
    /// - Throws: `MedicineError`, mapped from whatever Firestore reports.
    func recordMedicineRemoved(fromAisle aisle: String) async throws {
        try await adjustCount(forAisle: aisle, by: -1)
    }

    /// Upsert: creates the aisle document at `delta` if it doesn't exist yet, increments it otherwise.
    private func adjustCount(forAisle aisle: String, by delta: Int64) async throws {
        do {
            try await collection.document(aisle).setData(["medicineCount": FieldValue.increment(delta)], merge: true)
        } catch {
            throw Self.mapError(error)
        }
    }

    /// Maps a raw error from the Firestore SDK to a Domain-level `MedicineError`.
    /// So callers never see a Firestore type.
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

/// Firestore document representation of an aisle summary, carrying the Firestore-specific `@DocumentID`.
private struct AisleSummaryDTO: Codable {
    @DocumentID var code: String?
    var medicineCount: Int

    func toDomain() -> AisleSummary {
        AisleSummary(code: code ?? "", medicineCount: medicineCount)
    }
}
