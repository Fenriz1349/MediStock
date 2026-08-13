//
//  PasswordPolicy.swift
//  MediStock
//
//  Created by Julien Cotte on 07/08/2026.
//

import Foundation

/// One password strength criterion.
/// `CaseIterable` so the View can enumerate them to display a checklist without hardcoding the list itself.
enum PasswordRequirement: CaseIterable {
    case minLength
    case uppercase
    case lowercase
    case digit
    case specialCharacter
}

/// Password strength rules, mirroring the policy enforced server-side in the Firebase console.
/// Client-side only, for immediate feedback — not a replacement for the server-side check.
enum PasswordPolicy {
    static let minimumLength = 8

    /// - Parameter password: The candidate password.
    /// - Returns: Every requirement `password` does not currently satisfy; empty if it meets all of them.
    ///   Returning the unmet set (not just a `Bool`) lets the View show which specific criteria are missing.
    static func unmetRequirements(for password: String) -> Set<PasswordRequirement> {
        var unmet = Set<PasswordRequirement>()
        if password.count < minimumLength { unmet.insert(.minLength) }
        if !password.contains(where: \.isUppercase) { unmet.insert(.uppercase) }
        if !password.contains(where: \.isLowercase) { unmet.insert(.lowercase) }
        if !password.contains(where: \.isNumber) { unmet.insert(.digit) }
        if !password.contains(where: { !$0.isLetter && !$0.isNumber }) { unmet.insert(.specialCharacter) }
        return unmet
    }

    /// - Parameter password: The candidate password.
    /// - Returns: Whether `password` satisfies every requirement.
    static func isValid(_ password: String) -> Bool {
        unmetRequirements(for: password).isEmpty
    }
}
