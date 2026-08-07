//
//  FirestoreMedicineStore.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/// Firestore-backed implementation of `MedicineStoring`, mapping documents to/from `Medicine`.
final class FirestoreMedicineStore: MedicineStoring {
    private let collection = Firestore.firestore().collection("medicines")

    func observeMedicines() -> AsyncStream<[Medicine]> {
        AsyncStream { continuation in
            let listener = collection.addSnapshotListener { snapshot, error in
                guard let snapshot else {
                    if let error { print("Error observing medicines: \(error)") }
                    return
                }
                let medicines = snapshot.documents.compactMap { try? $0.data(as: MedicineDTO.self).toDomain() }
                continuation.yield(medicines)
            }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    func save(_ medicine: Medicine) async throws -> Medicine {
        let documentRef = medicine.id.map(collection.document) ?? collection.document()
        let dto = MedicineDTO(medicine: medicine)
        try await documentRef.setData(from: dto)
        var saved = medicine
        saved.id = documentRef.documentID
        return saved
    }

    func delete(_ medicine: Medicine) async throws {
        guard let id = medicine.id else { return }
        try await collection.document(id).delete()
    }
}

/// Firestore document representation of a medicine, carrying the Firestore-specific `@DocumentID`.
private struct MedicineDTO: Codable {
    @DocumentID var id: String?
    var name: String
    var stock: Int
    var aisle: String

    init(medicine: Medicine) {
        self.id = medicine.id
        self.name = medicine.name
        self.stock = medicine.stock
        self.aisle = medicine.aisle
    }

    func toDomain() -> Medicine {
        Medicine(id: id, name: name, stock: stock, aisle: aisle)
    }
}
