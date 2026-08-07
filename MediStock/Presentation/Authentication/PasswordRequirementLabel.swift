//
//  PasswordRequirementLabel.swift
//  MediStock
//
//  Created by Julien Cotte on 07/08/2026.
//

import Foundation

/// Localized text for each password requirement, kept out of `PasswordPolicy` (Domain) since it
/// touches the display language.
extension PasswordRequirement {
    var localizedDescription: String {
        switch self {
        case .minLength: String(localized: "auth.password.rule.minLength")
        case .uppercase: String(localized: "auth.password.rule.uppercase")
        case .lowercase: String(localized: "auth.password.rule.lowercase")
        case .digit: String(localized: "auth.password.rule.digit")
        case .specialCharacter: String(localized: "auth.password.rule.specialCharacter")
        }
    }
}
