//
//  AisleCode.swift
//  MediStock
//
//  Created by Julien Cotte on 06/08/2026.
//

import Foundation

/// Business rule: an aisle is identified by a free-form code (e.g. "AD56", "3A4", "7") — no
/// assumption on its shape, real warehouses/hospitals use mixed alphanumeric conventions, not just
/// plain numbers. Stored as-is in `Medicine.aisle` (kept a plain `String`, no schema change: the
/// Firestore `medicines` collection may be read by other apps/services).
enum AisleCode {

    /// Formats a code for display, optionally prefixed with a label (e.g. "Rayon AD56"). Pass
    /// `nil` to get just the code. This rule doesn't know about localization — callers resolve
    /// and pass in whatever label they want.
    static func format(code: String, aisleLabel: String?) -> String {
        guard let aisleLabel else { return code }
        return "\(aisleLabel) \(code)"
    }

    /// Removes a redundant label word (e.g. "Rayon"/"Aisle") a user may have typed along with the
    /// code itself, so the stored code stays just the code (e.g. "Rayon AD56" -> "AD56").
    /// Case-insensitive. Assumes the label itself is never part of a real code, an accepted edge
    /// case given how rare and impractical that would be in practice.
    static func stripLabel(_ label: String, from code: String) -> String {
        code.replacingOccurrences(of: label, with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespaces)
    }

    /// Orders two aisle codes the way Finder orders file names: digit runs compare numerically
    /// ("AD2" before "AD10"), everything else compares as text.
    static func areInOrder(_ lhs: String, _ rhs: String) -> Bool {
        lhs.localizedStandardCompare(rhs) == .orderedAscending
    }
}
