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
    func observeSession() -> AsyncStream<AppUser?> {
        AsyncStream { continuation in
            let handle = Auth.auth().addStateDidChangeListener { _, user in
                continuation.yield(user.map { AppUser(uid: $0.uid, email: $0.email) })
            }
            continuation.onTermination = { _ in Auth.auth().removeStateDidChangeListener(handle) }
        }
    }

    func signUp(email: String, password: String) async throws -> AppUser {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return AppUser(uid: result.user.uid, email: result.user.email)
    }

    func signIn(email: String, password: String) async throws -> AppUser {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return AppUser(uid: result.user.uid, email: result.user.email)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func deleteAccount() async throws {
        try await Auth.auth().currentUser?.delete()
    }
}
