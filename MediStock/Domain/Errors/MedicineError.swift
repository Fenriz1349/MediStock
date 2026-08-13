//
//  MedicineError.swift
//  MediStock
//
//  Created by Julien Cotte on 07/08/2026.
//

import Foundation

/// Typed failures for medicine/history reads and writes, mapped from Firestore's error codes.
/// Shared by `MedicineFormViewModel` and `MedicineDetailViewModel` — same stores, same failure causes.
enum MedicineError: Error, Equatable {
    /// The request failed due to a connectivity problem, detected by `NetworkMonitoring`.
    case network(NetworkError)
    /// Firestore refused the request — the security rules don't allow it.
    /// Shouldn't normally happen here, the app already requires being signed in for every read/write.
    case permissionDenied
    /// Any other failure, not specifically handled above.
    case unknown
}
