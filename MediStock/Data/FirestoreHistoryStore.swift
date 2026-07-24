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
final class FirestoreHistoryStore: HistoryStoring {
    private let collection = Firestore.firestore().collection("history")

    func observeHistory(forMedicineId medicineId: String) -> AsyncStream<[HistoryEntry]> {
        AsyncStream { continuation in
            let listener = collection
                .whereField("medicineId", isEqualTo: medicineId)
                .addSnapshotListener { snapshot, error in
                    guard let snapshot else {
                        if let error { print("Error observing history: \(error)") }
                        return
                    }
                    let entries = snapshot.documents.compactMap { try? $0.data(as: HistoryEntryDTO.self).toDomain() }
                    continuation.yield(entries)
                }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    func record(_ entry: HistoryEntry) async throws {
        let documentRef = entry.id.map(collection.document) ?? collection.document()
        var dto = HistoryEntryDTO(entry: entry)
        dto.id = documentRef.documentID
        try await documentRef.setData(from: dto)
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
