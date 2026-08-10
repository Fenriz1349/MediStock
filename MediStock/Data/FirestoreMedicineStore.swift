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
        observe(collection)
    }

    /// - Parameters:
    ///   - sortOption: How to order the results — translates directly to `.order(by:)`.
    ///     `.none` leaves the query unordered.
    ///   - ascending: The sort direction. Ignored when `sortOption` is `.none`.
    func observeMedicines(sortedBy sortOption: SortOption, ascending: Bool) -> AsyncStream<[Medicine]> {
        switch sortOption {
        case .none:
            observe(collection)
        case .name:
            observe(collection.order(by: "name", descending: !ascending))
        case .stock:
            observe(collection.order(by: "stock", descending: !ascending))
        }
    }

    /// - Parameter aisle: The exact aisle code to filter on.
    func observeMedicines(inAisle aisle: String) -> AsyncStream<[Medicine]> {
        observe(collection.whereField("aisle", isEqualTo: aisle))
    }

    /// Shared listener setup for every `observeMedicines...` variant above.
    /// Only the `query` itself differs between them.
    private func observe(_ query: Query) -> AsyncStream<[Medicine]> {
        AsyncStream { continuation in
            let listener = query.addSnapshotListener { snapshot, error in
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

    /// - Parameter medicine: The medicine to create or update (existing when `id` is non-nil).
    /// - Returns: The saved medicine, with `id` set.
    /// - Throws: `MedicineError`, mapped from whatever Firestore reports.
    func save(_ medicine: Medicine) async throws -> Medicine {
        let documentRef = medicine.id.map(collection.document) ?? collection.document()
        let dto = MedicineDTO(medicine: medicine)
        do {
            try await documentRef.setData(from: dto)
        } catch {
            throw Self.mapError(error)
        }
        var saved = medicine
        saved.id = documentRef.documentID
        return saved
    }

    /// - Parameter medicine: The medicine to delete. A no-op if it has no `id`.
    /// - Throws: `MedicineError`, mapped from whatever Firestore reports.
    func delete(_ medicine: Medicine) async throws {
        guard let id = medicine.id else { return }
        do {
            try await collection.document(id).delete()
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
            return .networkUnavailable
        case .permissionDenied:
            return .permissionDenied
        default:
            return .unknown
        }
    }
}

/// Firestore document representation of a medicine, carrying the Firestore-specific `@DocumentID`.
private struct MedicineDTO: Codable {
    @DocumentID var id: String?
    var name: String
    var stock: Int
    var aisle: String

    /// `id` is intentionally left `nil` here — `@DocumentID` is only ever meant to be populated by Firestore on read.
    /// Setting it manually before a write (even to an existing medicine's own id) triggers a Firestore SDK warning.
    /// Since the document's id is never actually a field.
    init(medicine: Medicine) {
        self.name = medicine.name
        self.stock = medicine.stock
        self.aisle = medicine.aisle
    }

    func toDomain() -> Medicine {
        Medicine(id: id, name: name, stock: stock, aisle: aisle)
    }
}
