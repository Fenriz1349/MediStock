//
//  MedicineNameFormat.swift
//  MediStock
//
//  Created by Julien Cotte on 10/08/2026.
//

import Foundation

/// Business rule: a medicine name is always stored capitalized (first letter upper, rest lower).
/// Enforced at write time, so name search can normalize a typed prefix the same way.
enum MedicineNameFormat {
    /// - Parameter name: The raw name, as typed by the user.
    /// - Returns: `name` with its first character uppercased and the rest lowercased.
    ///   Unicode-aware for the first character.
    ///   No accent normalization — an accepted limitation, medicine names rarely carry one.
    static func capitalized(_ name: String) -> String {
        guard let first = name.first else { return name }
        return first.uppercased() + name.dropFirst().lowercased()
    }
}
