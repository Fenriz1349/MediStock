//
//  AisleStoringDouble.swift
//  MediStockTests
//
//  Created by Julien Cotte on 16/08/2026.
//

import Foundation
@testable import MediStock

/// In-memory fake of `AisleStoring` for testing, with a controllable aisles stream.
final class AisleStoringDouble: AisleStoring {
    private(set) var addedToAisles: [String] = []
    private(set) var removedFromAisles: [String] = []
    var recordError: Error?

    private let aislesStream: AsyncStream<[AisleSummary]>
    private let aislesContinuation: AsyncStream<[AisleSummary]>.Continuation

    init() {
        var continuation: AsyncStream<[AisleSummary]>.Continuation!
        aislesStream = AsyncStream { continuation = $0 }
        aislesContinuation = continuation
    }

    func observeAisles() -> AsyncStream<[AisleSummary]> {
        aislesStream
    }

    func emit(_ aisles: [AisleSummary]) {
        aislesContinuation.yield(aisles)
    }

    func recordMedicineAdded(toAisle aisle: String) async throws {
        if let recordError { throw recordError }
        addedToAisles.append(aisle)
    }

    func recordMedicineRemoved(fromAisle aisle: String) async throws {
        if let recordError { throw recordError }
        removedFromAisles.append(aisle)
    }
}
