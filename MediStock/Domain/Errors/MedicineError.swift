//
//  MedicineError.swift
//  MediStock
//
//  Created by Julien Cotte on 07/08/2026.
//

import Foundation

/// Typed failures for medicine/history reads and writes, mapped from Firestore's error codes by
/// `FirestoreMedicineStore`/`FirestoreHistoryStore` so the rest of the app never sees a Firestore
/// type. Shared by `CatalogViewModel` and `MedicineDetailViewModel` — both hit the same stores and
/// can fail for the same reasons. No localized text here — resolving that is a display concern the
/// View handles, same as `AuthenticationError`.
enum MedicineError: Error, Equatable {
    /// The request failed because the device has no network connectivity.
    case networkUnavailable
    /// Firestore refused the request — the security rules don't allow it (shouldn't normally
    /// happen here, the app already requires being signed in for every read/write).
    case permissionDenied
    /// Any other failure, not specifically handled above.
    case unknown
}
