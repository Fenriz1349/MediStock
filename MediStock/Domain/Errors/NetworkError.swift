//
//  NetworkError.swift
//  MediStock
//
//  Created by Julien Cotte on 10/08/2026.
//

import Foundation

/// Typed connectivity failures, reported by `NetworkMonitoring`.
/// Wrapped by `MedicineError`/`AuthenticationError` as `.network(NetworkError)`, not duplicated in each.
enum NetworkError: Error, Equatable {
    /// The device has no active network interface.
    case notConnected
    /// The device is connected, but the backend could not be reached.
    /// Captive portal, VPN, server down, or the request itself timed out.
    case serverUnreachable
}
