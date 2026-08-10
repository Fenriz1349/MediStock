//
//  AuthenticationErrorMessage.swift
//  MediStock
//
//  Created by Julien Cotte on 07/08/2026.
//

import Foundation

/// Localized text for each `AuthenticationError` case.
/// Kept out of the Domain/ViewModel layers since it touches the display language.
extension AuthenticationError {
    var localizedMessage: String {
        switch self {
        case .wrongCredentials: String(localized: "auth.error.wrongCredentials")
        case .emailAlreadyInUse: String(localized: "auth.error.emailAlreadyInUse")
        case .weakPassword: String(localized: "auth.error.weakPassword")
        case .requiresRecentLogin: String(localized: "auth.error.requiresRecentLogin")
        case .network(let networkError): networkError.localizedMessage
        case .unknown: String(localized: "auth.error.unknown")
        }
    }
}
