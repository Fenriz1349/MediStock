//
//  HistoryEntryLocalized.swift
//  MediStock
//
//  Created by Julien Cotte on 12/08/2026.
//

import Foundation

/// Localized, human-readable view of a `HistoryEntry`.
/// Parses `FirestoreHistoryStore`'s plain-English `action`/`details`, falling back to the raw string.
struct HistoryEntryLocalized {
    let user: String
    let date: String
    let action: String
    let details: String

    init(_ entry: HistoryEntry) {
        user = entry.user
        date = entry.timestamp.formatted(date: .abbreviated, time: .shortened)
        action = Self.localizedAction(entry.action)
        details = Self.localizedDetails(entry.details)
    }

    /// Matches `"Added <name>"`, `"Updated <name>"` and `"<Increased/Decreased> stock of <name> by <delta>"`.
    /// Those are the only three shapes `FirestoreHistoryStore.record(action:details:medicineId:)` writes.
    private static func localizedAction(_ raw: String) -> String {
        if let name = raw.removingPrefix("Added ") {
            return String(localized: "medicineDetail.history.action.added", defaultValue: "Ajout de \(name)")
        }
        if let name = raw.removingPrefix("Updated ") {
            return String(localized: "medicineDetail.history.action.updated", defaultValue: "Modification de \(name)")
        }
        if let (name, delta) = stockChange(raw, verb: "Increased") {
            return String(localized: "medicineDetail.history.action.stockIncreased",
                          defaultValue: "Augmentation du stock de \(name) de \(delta)")
        }
        if let (name, delta) = stockChange(raw, verb: "Decreased") {
            return String(localized: "medicineDetail.history.action.stockDecreased",
                          defaultValue: "Diminution du stock de \(name) de \(delta)")
        }
        return raw
    }

    /// Matches `"Added new medicine with initial stock of <n>"`, `"Updated medicine details"` and
    /// `"Stock changed from <a> to <b>"` — the three `details` shapes written alongside the actions above.
    private static func localizedDetails(_ raw: String) -> String {
        if raw == "Updated medicine details" {
            return String(localized: "medicineDetail.history.details.updated", defaultValue: "Détails mis à jour")
        }
        if let stockText = raw.removingPrefix("Added new medicine with initial stock of "), let stock = Int(stockText) {
            return String(localized: "medicineDetail.history.details.added", defaultValue: "Stock initial de \(stock)")
        }
        if let (from, to) = stockRange(raw) {
            return String(localized: "medicineDetail.history.details.stockChanged",
                          defaultValue: "Stock passé de \(from) à \(to)")
        }
        return raw
    }

    /// Parses `"<verb> stock of <name> by <delta>"`.
    /// `nil` if `raw` doesn't start with `verb`, or `delta` isn't a valid integer.
    private static func stockChange(_ raw: String, verb: String) -> (name: String, delta: Int)? {
        guard let rest = raw.removingPrefix("\(verb) stock of "),
              let separatorRange = rest.range(of: " by ", options: .backwards),
              let delta = Int(rest[separatorRange.upperBound...])
        else { return nil }
        return (String(rest[..<separatorRange.lowerBound]), delta)
    }

    /// Parses `"Stock changed from <a> to <b>"`, `nil` if either value isn't a valid integer.
    private static func stockRange(_ raw: String) -> (from: Int, to: Int)? {
        guard let rest = raw.removingPrefix("Stock changed from "),
              let separatorRange = rest.range(of: " to "),
              let from = Int(rest[..<separatorRange.lowerBound]),
              let to = Int(rest[separatorRange.upperBound...])
        else { return nil }
        return (from, to)
    }
}

private extension String {
    /// `nil` if `self` doesn't start with `prefix`, the remainder otherwise.
    func removingPrefix(_ prefix: String) -> String? {
        hasPrefix(prefix) ? String(dropFirst(prefix.count)) : nil
    }
}
