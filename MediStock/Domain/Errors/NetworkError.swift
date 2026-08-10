//
//  NetworkError.swift
//  MediStock
//
//  Created by Julien Cotte on 10/08/2026.
//

import Foundation

/// Typed connectivity failures, reported by `NetworkMonitoring`.
/// Wrapped by `MedicineError`/`AuthenticationError` as `.network(NetworkError)`.
/// Not duplicated as a separate case in each.
/// `NetworkMonitoring` is the single source of truth for *why* the network isn't available.
/// The other stores only care that it isn't.
enum NetworkError: Error, Equatable {
    /// The device has no active network interface.
    case notConnected
    /// The device is connected, but the backend could not be reached.
    /// Captive portal, VPN, server down, or the request itself timed out.
    case serverUnreachable
}
