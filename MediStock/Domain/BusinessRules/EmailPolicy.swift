//
//  EmailPolicy.swift
//  MediStock
//
//  Created by Julien Cotte on 11/08/2026.
//

import Foundation

/// Business rule: a plausible-looking email address, checked client-side for immediate feedback.
/// Firebase Auth remains the actual source of truth.
/// This only catches obvious typos before a round-trip — it doesn't need to be exhaustive.
enum EmailPolicy {
    private static let regex = try! NSRegularExpression(pattern: "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")

    /// - Parameter email: The candidate email address.
    /// - Returns: Whether `email` looks like a plausible address (something@something.something).
    static func isValid(_ email: String) -> Bool {
        let range = NSRange(email.startIndex..., in: email)
        return regex.firstMatch(in: email, range: range) != nil
    }
}
