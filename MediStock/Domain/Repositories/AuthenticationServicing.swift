//
//  AuthenticationServicing.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import Foundation

/// Access to the current authentication session and account operations.
protocol AuthenticationServicing {
    /// An ongoing stream of the signed-in user, `nil` when signed out.
    func observeSession() -> AsyncStream<AppUser?>

    /// Creates a new account and signs in as it.
    func signUp(email: String, password: String) async throws -> AppUser

    /// Signs in to an existing account.
    func signIn(email: String, password: String) async throws -> AppUser

    /// Ends the current session.
    func signOut() throws

    /// Permanently deletes the signed-in user's account (App Store guideline 5.1.1(v) requires this
    /// whenever an app supports in-app account creation).
    func deleteAccount() async throws
}
