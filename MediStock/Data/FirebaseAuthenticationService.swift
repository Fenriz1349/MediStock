//
//  FirebaseAuthenticationService.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import Foundation
import FirebaseAuth

/// Firebase Authentication-backed implementation of `AuthenticationServicing`.
final class FirebaseAuthenticationService: AuthenticationServicing {
    /// - Returns: A stream that yields the current session on subscription and again every time
    ///   Firebase Auth's sign-in state changes, `nil` when signed out.
    func observeSession() -> AsyncStream<AppUser?> {
        AsyncStream { continuation in
            let handle = Auth.auth().addStateDidChangeListener { _, user in
                continuation.yield(user.map { AppUser(uid: $0.uid, email: $0.email) })
            }
            continuation.onTermination = { _ in Auth.auth().removeStateDidChangeListener(handle) }
        }
    }

    /// - Parameters:
    ///   - email: The email address to register the new account with.
    ///   - password: The password to set for the new account.
    /// - Returns: The newly created user's session.
    func signUp(email: String, password: String) async throws -> AppUser {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return AppUser(uid: result.user.uid, email: result.user.email)
    }

    /// - Parameters:
    ///   - email: The account's email address.
    ///   - password: The account's password.
    /// - Returns: The signed-in user's session.
    func signIn(email: String, password: String) async throws -> AppUser {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return AppUser(uid: result.user.uid, email: result.user.email)
    }

    /// Signs out the current Firebase session locally. Does not touch the account itself.
    func signOut() throws {
        try Auth.auth().signOut()
    }

    /// Permanently deletes the currently signed-in Firebase user. A no-op if there is no signed-in
    /// user (shouldn't normally happen — this is only reachable while a session exists).
    /// - Throws: Firebase's `requiresRecentLogin` error if the session is too old — Firebase
    ///   requires a fresh sign-in before allowing account deletion, as a safety measure against a
    ///   stale/stolen session deleting the account.
    func deleteAccount() async throws {
        try await Auth.auth().currentUser?.delete()
    }
}
