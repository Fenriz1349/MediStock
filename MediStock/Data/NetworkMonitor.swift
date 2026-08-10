//
//  NetworkMonitor.swift
//  MediStock
//
//  Created by Julien Cotte on 10/08/2026.
//

import Foundation
import Network

/// `NWPathMonitor`/`URLSession`-backed implementation of `NetworkMonitoring`.
/// Also `ObservableObject`, so it can be injected directly into the environment for a live status banner.
/// Same pattern as `ToastyManager`, on top of being passed to ViewModels as `NetworkMonitoring`.
@MainActor
final class NetworkMonitor: NetworkMonitoring, ObservableObject {
    @Published private(set) var isConnected = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.juliencotte.medistock.networkmonitor")
    /// Pinged to confirm reachability. Firestore itself.
    /// So a successful response proves both internet access and backend availability in one shot.
    private let reachabilityURL = URL(string: "https://firestore.googleapis.com")!

    /// Starts the underlying `NWPathMonitor`.
    /// Updates `isConnected` on the main actor as the interface status changes.
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            Task { @MainActor in self?.isConnected = connected }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }

    /// - Returns: `false` immediately if the interface itself is down.
    ///   Otherwise, whether a real round-trip to the backend succeeded.
    func verifyReachable() async -> Bool {
        guard isConnected else { return false }
        return await ping()
    }

    /// Sends a short HEAD request to the backend.
    /// Any HTTP response means reachable; a thrown error (timeout, no route) means it isn't.
    private func ping() async -> Bool {
        var request = URLRequest(url: reachabilityURL)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 3
        // Always hit the network: a cached response would make us look reachable while offline.
        request.cachePolicy = .reloadIgnoringLocalCacheData
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            return response is HTTPURLResponse
        } catch {
            return false
        }
    }
}
