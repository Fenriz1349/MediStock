//
//  MedicinePolicy.swift
//  MediStock
//
//  Created by Julien Cotte on 11/08/2026.
//

import Foundation

/// Business rules for the medicine creation/edit form.
/// Each check operates on the raw field text, matching what a text field's live validator needs.
/// Not on the already-parsed `Medicine` fields.
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
}
