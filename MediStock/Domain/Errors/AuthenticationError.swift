//
//  AuthenticationError.swift
//  MediStock
//
//  Created by Julien Cotte on 07/08/2026.
//

import Foundation

/// Typed authentication failures, mapped from Firebase's error codes by `FirebaseAuthenticationService`
/// so the rest of the app never sees a Firebase type. No localized text here — resolving that is a
/// display concern the View handles, same as `AisleCode`/`PasswordPolicy`.
enum AuthenticationError: Error, Equatable {
    /// Sign-in failed because the email/password combination is wrong, or the account doesn't
    /// exist. Firebase deliberately merges these two cases (email enumeration protection), so this
    /// type does too.
    case wrongCredentials
    /// Sign-up failed because an account already exists for that email.
    case emailAlreadyInUse
    /// Sign-up (or a server-side policy change) rejected the password as too weak.
    case weakPassword
    /// The account-deletion request was refused because the session is too old — Firebase requires
    /// a fresh sign-in before allowing this sensitive operation.
    case requiresRecentLogin
    /// The request failed because the device has no network connectivity.
    case networkUnavailable
    /// Any other failure, not specifically handled above.
    case unknown
}
