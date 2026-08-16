//
//  MedicinePolicy.swift
//  MediStock
//
//  Created by Julien Cotte on 11/08/2026.
//

import Foundation

/// Business rules for the medicine creation/edit form.
/// Each check operates on the raw field text, not the already-parsed `Medicine` fields.
enum MedicinePolicy {
    static let minimumNameLength = 2

    /// - Parameter name: The raw name, as typed by the user.
    /// - Returns: Whether `name` is at least `minimumNameLength` characters.
    ///   Ignoring surrounding whitespace.
    static func isValidName(_ name: String) -> Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).count >= minimumNameLength
    }

    /// - Parameter aisle: The raw aisle code, as typed by the user.
    /// - Returns: Whether `aisle` isn't empty, ignoring surrounding whitespace.
    static func isValidAisle(_ aisle: String) -> Bool {
        !aisle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// - Parameter stockText: The raw stock field text, as typed by the user.
    /// - Returns: Whether `stockText` parses to a non-negative integer.
    static func isValidStock(_ stockText: String) -> Bool {
        guard let stock = Int(stockText) else { return false }
        return stock >= 0
    }

    /// Strips everything but digits — no separator, stock is always a whole number.
    /// Applied live as the user types, so a pasted or hardware-keyboard letter can't sneak in.
    /// Even though the field's own numeric keyboard already discourages it.
    /// - Parameter stockText: The raw stock field text, as typed by the user.
    static func sanitizedStock(_ stockText: String) -> String {
        stockText.filter(\.isNumber)
    }

    /// Strips `/`, since the aisle code is used as-is as an `aisles` collection document id —
    /// Firestore treats `/` as a path separator, which would break that document lookup.
    /// - Parameter aisle: The raw aisle field text, as typed by the user.
    static func sanitizedAisle(_ aisle: String) -> String {
        aisle.filter { $0 != "/" }
    }
}
