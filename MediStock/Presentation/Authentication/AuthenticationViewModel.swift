//
//  AuthenticationViewModel.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import Foundation

/// Presentation-layer state and actions for the authentication screen and app-wide session.
@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published private(set) var session: AppUser?

    private let authenticationService: AuthenticationServicing
    private var observationTask: Task<Void, Never>?

    /// - Parameter authenticationService: Domain-level auth abstraction, kept behind a protocol so
    ///   this ViewModel never depends on Firebase directly.
    init(authenticationService: AuthenticationServicing) {
        self.authenticationService = authenticationService
    }

    /// Starts observing the current authentication session. Call once when the app appears.
    func listen() {
        observationTask?.cancel()
        observationTask = Task { [weak self] in
            guard let stream = self?.authenticationService.observeSession() else { return }
            for await user in stream {
                self?.session = user
            }
        }
    }

    /// Signs in with an existing account and updates `session` on success.
    /// - Parameters:
    ///   - email: The account's email address.
    ///   - password: The account's password.
    func signIn(email: String, password: String) async {
        do {
            session = try await authenticationService.signIn(email: email, password: password)
        } catch {
            print("Error signing in: \(error.localizedDescription)")
        }
    }

    /// Creates a new account and updates `session` on success.
    /// - Parameters:
    ///   - email: The email address to register the new account with.
    ///   - password: The password to set for the new account.
    func signUp(email: String, password: String) async {
        do {
            session = try await authenticationService.signUp(email: email, password: password)
        } catch {
            print("Error creating user: \(error.localizedDescription)")
        }
    }

    /// Signs out the current session locally. Does not touch the account itself — use
    /// `deleteAccount()` to remove it (App Store guideline 5.1.1(v)).
    func signOut() {
        do {
            try authenticationService.signOut()
            session = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    /// Permanently deletes the account and clears the session. Irreversible — the View is
    /// responsible for confirming with the user before calling this.
    func deleteAccount() async {
        do {
            try await authenticationService.deleteAccount()
            session = nil
        } catch {
            // Full error dump, not just localizedDescription: Firebase's requiresRecentLogin case
            // in particular carries the actionable info (its error code) outside the description.
            print("Error deleting account: \(error)")
        }
    }

    deinit {
        observationTask?.cancel()
    }
}
