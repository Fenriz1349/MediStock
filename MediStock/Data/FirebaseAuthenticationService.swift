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
    var currentUser: AppUser? {
        Auth.auth().currentUser.map { AppUser(uid: $0.uid, email: $0.email) }
    }

    /// - Returns: A stream that yields the current session on subscription and again every time Firebase
    ///   Auth's sign-in state changes, `nil` when signed out.
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
    /// - Throws: `AuthenticationError`, mapped from whatever Firebase reports.
    func signUp(email: String, password: String) async throws -> AppUser {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return AppUser(uid: result.user.uid, email: result.user.email)
        } catch {
            throw Self.mapError(error)
        }
    }

    /// - Parameters:
    ///   - email: The account's email address.
    ///   - password: The account's password.
    /// - Returns: The signed-in user's session.
    /// - Throws: `AuthenticationError`, mapped from whatever Firebase reports.
    func signIn(email: String, password: String) async throws -> AppUser {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return AppUser(uid: result.user.uid, email: result.user.email)
        } catch {
            throw Self.mapError(error)
        }
    }

    /// Signs out the current Firebase session locally. Does not touch the account itself.
    /// - Throws: `AuthenticationError`, mapped from whatever Firebase reports.
    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            throw Self.mapError(error)
        }
    }

    /// Permanently deletes the currently signed-in Firebase user.
    /// A no-op if there is no signed-in user.
    /// Shouldn't normally happen here — this is only reachable while a session exists.
    /// - Throws: `AuthenticationError.requiresRecentLogin` if the session is too old.
    ///   Firebase requires a fresh sign-in before allowing account deletion.
    ///   This is a safety measure against a stale/stolen session deleting the account.
    ///   Otherwise `AuthenticationError`, mapped from whatever Firebase reports.
    func deleteAccount() async throws {
        do {
            try await Auth.auth().currentUser?.delete()
        } catch {
            throw Self.mapError(error)
        }
    }

    /// Maps a raw error from the Firebase Auth SDK to a Domain-level `AuthenticationError`.
    /// So callers never see a Firebase type.
    /// - Parameter error: The error thrown by a Firebase Auth SDK call.
    /// - Returns: The corresponding `AuthenticationError`.
    ///   Or `.unknown` if it isn't one of the specific cases this app handles.
    private static func mapError(_ error: Error) -> AuthenticationError {
        guard let code = AuthErrorCode.Code(rawValue: (error as NSError).code) else { return .unknown }
        switch code {
        case .wrongPassword, .userNotFound, .invalidCredential:
            return .wrongCredentials
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .requiresRecentLogin:
            return .requiresRecentLogin
        case .networkError:
            return .network(.serverUnreachable)
        default:
            return .unknown
        }
    }
}
