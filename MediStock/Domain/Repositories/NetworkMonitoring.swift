//
//  NetworkMonitoring.swift
//  MediStock
//
//  Created by Julien Cotte on 10/08/2026.
//

import Foundation

/// Tracks connectivity in two complementary ways.
/// `isConnected` is the device's interface status, updated live.
/// Cheap, but reflects the interface only, so it can be `true` with no usable internet
/// (captive portal, VPN).
/// `verifyReachable()` is an actual round-trip to the backend, the source of truth before a write.
protocol NetworkMonitoring {
    /// Whether the device currently has an active network interface.
    /// Use for a live status banner — not as proof the backend is reachable.
    var isConnected: Bool { get }

    /// Confirms real reachability of the backend with a round-trip request.
    /// Call before a write so it can be cancelled before Firestore queues it offline.
    /// - Throws: `NetworkError.notConnected` if the interface itself is down.
    ///   `NetworkError.serverUnreachable` if the interface is up but the backend didn't respond.
    func verifyReachable() async throws
}
