//
//  NetworkMonitor.swift
//  MediStock
//
//  Created by Julien Cotte on 10/08/2026.
//

import Foundation
import Network

/// `NWPathMonitor`/`URLSession`-backed implementation of `NetworkMonitoring`.
final class NetworkMonitor: NetworkMonitoring {
    /// Optimistic default.
    /// Most of the time the device is actually connected.
    /// And this self-corrects near-instantly once the first real path update arrives.
    /// The alternative (defaulting to `false`) would mean looking offline while actually connected.
    /// For a moment, or longer.
    /// Worse for this app's one use of `isConnected` — whether to show `OfflineView` at launch.
    private(set) var isConnected = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.juliencotte.medistock.networkmonitor")
    /// Pinged to confirm reachability. Firestore itself.
    /// So a successful response proves both internet access and backend availability in one shot.
    private let reachabilityURL = URL(string: "https://firestore.googleapis.com")!
    private var continuation: AsyncStream<Bool>.Continuation?

    /// Starts the underlying `NWPathMonitor`.
    /// `pathUpdateHandler` is assigned before `start(queue:)` is called, not after.
    /// The other way around risks the very first path evaluation firing into no handler at all.
    /// Never reported again until the status actually changes later.
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            self?.isConnected = connected
            self?.continuation?.yield(connected)
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }

    func observeConnectivity() -> AsyncStream<Bool> {
        AsyncStream { [weak self] continuation in
            guard let self else { return }
            continuation.yield(self.isConnected)
            self.continuation = continuation
        }
    }

    func verifyReachable() async throws {
        guard isConnected else { throw NetworkError.notConnected }
        guard await ping() else { throw NetworkError.serverUnreachable }
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
