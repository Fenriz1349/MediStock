//
//  NetworkMonitoringDouble.swift
//  MediStockTests
//
//  Created by Julien Cotte on 12/08/2026.
//

import Foundation
@testable import MediStock

/// In-memory fake of `NetworkMonitoring` for testing, with a controllable connectivity stream.
final class NetworkMonitoringDouble: NetworkMonitoring {
    var isConnected: Bool
    var verifyReachableError: NetworkError?
    /// A real suspension point for `verifyReachable()`, off by default.
    /// Without it, a VM action can race to completion before a test ever gets to observe `isLoading == true`
    /// — set this in tests that need a reliably observable in-flight window.
    var verifyReachableDelayNanoseconds: UInt64 = 0

    private let connectivityStream: AsyncStream<Bool>
    private let connectivityContinuation: AsyncStream<Bool>.Continuation

    init(isConnected: Bool = true) {
        self.isConnected = isConnected
        var continuation: AsyncStream<Bool>.Continuation!
        connectivityStream = AsyncStream { continuation = $0 }
        connectivityContinuation = continuation
    }

    func observeConnectivity() -> AsyncStream<Bool> {
        connectivityStream
    }

    func emit(_ connected: Bool) {
        isConnected = connected
        connectivityContinuation.yield(connected)
    }

    func verifyReachable() async throws {
        if verifyReachableDelayNanoseconds > 0 {
            try? await Task.sleep(nanoseconds: verifyReachableDelayNanoseconds)
        }
        if let verifyReachableError { throw verifyReachableError }
    }
}
