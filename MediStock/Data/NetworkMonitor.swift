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
    private(set) var isConnected: Bool

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.juliencotte.medistock.networkmonitor")
    /// Pinged to confirm reachability. Firestore itself.
    /// So a successful response proves both internet access and backend availability in one shot.
    private let reachabilityURL = URL(string: "https://firestore.googleapis.com")!

    /// Starts the underlying `NWPathMonitor`.
    /// `isConnected` is also set once synchronously right after starting, from `monitor.currentPath`.
    /// Without that, it would keep the placeholder value set below until the first callback fires from
    /// `observeConnectivity()`. Which could be wrong for a moment right after launch.
    init() {
        isConnected = false
        monitor.start(queue: queue)
        isConnected = monitor.currentPath.status == .satisfied
    }

    deinit {
        monitor.cancel()
    }

    func observeConnectivity() -> AsyncStream<Bool> {
        AsyncStream { [weak self] continuation in
            guard let self else { return }
            continuation.yield(self.isConnected)
            self.monitor.pathUpdateHandler = { [weak self] path in
                let connected = path.status == .satisfied
                self?.isConnected = connected
                continuation.yield(connected)
            }
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
