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

    func signIn(email: String, password: String) async {
        do {
            session = try await authenticationService.signIn(email: email, password: password)
        } catch {
            print("Error signing in: \(error.localizedDescription)")
        }
    }

    func signUp(email: String, password: String) async {
        do {
            session = try await authenticationService.signUp(email: email, password: password)
        } catch {
            print("Error creating user: \(error.localizedDescription)")
        }
    }

    func signOut() {
        do {
            try authenticationService.signOut()
            session = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    func deleteAccount() async {
        do {
            try await authenticationService.deleteAccount()
            session = nil
        } catch {
            print("Error deleting account: \(error.localizedDescription)")
        }
    }

    deinit {
        observationTask?.cancel()
    }
}
