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
    /// Reset to `nil` at the start of every action, then set again on failure.
    /// The View observes this to trigger a toast, resolving the localized message itself.
    /// This ViewModel never touches the display language.
    @Published private(set) var error: AuthenticationError?
    /// `true` for the duration of an action, so the View can show a loading indicator.
    @Published private(set) var isLoading = false

    private let authenticationService: AuthenticationServicing
    private let networkMonitor: NetworkMonitoring
    private var observationTask: Task<Void, Never>?

    /// - Parameters:
    ///   - authenticationService: Domain-level auth abstraction, kept behind a protocol so this
    ///     ViewModel never depends on Firebase directly.
    ///   - networkMonitor: Checked before every write. See `verifyNetworkReachable()`.
    init(authenticationService: AuthenticationServicing, networkMonitor: NetworkMonitoring) {
        self.authenticationService = authenticationService
        self.networkMonitor = networkMonitor
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
        error = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await verifyNetworkReachable()
            session = try await authenticationService.signIn(email: email, password: password)
        } catch let authError as AuthenticationError {
            error = authError
        } catch {
            self.error = .unknown
        }
    }

    /// Creates a new account and updates `session` on success.
    /// - Parameters:
    ///   - email: The email address to register the new account with.
    ///   - password: The password to set for the new account.
    func signUp(email: String, password: String) async {
        error = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await verifyNetworkReachable()
            session = try await authenticationService.signUp(email: email, password: password)
        } catch let authError as AuthenticationError {
            error = authError
        } catch {
            self.error = .unknown
        }
    }

    /// Signs out the current session locally. Does not touch the account itself.
    /// Use `deleteAccount()` to remove it (App Store guideline 5.1.1(v)).
    func signOut() {
        error = nil
        do {
            try authenticationService.signOut()
            session = nil
        } catch let authError as AuthenticationError {
            error = authError
        } catch {
            self.error = .unknown
        }
    }

    /// Permanently deletes the account and clears the session. Irreversible.
    /// The View is responsible for confirming with the user before calling this.
    func deleteAccount() async {
        error = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await verifyNetworkReachable()
            try await authenticationService.deleteAccount()
            session = nil
        } catch let authError as AuthenticationError {
            error = authError
        } catch {
            self.error = .unknown
        }
    }

    /// Called before every write, so a lack of connectivity surfaces immediately as a typed error.
    /// - Throws: `AuthenticationError.network`, wrapping whatever `NetworkError` `networkMonitor` reports.
    private func verifyNetworkReachable() async throws {
        do {
            try await networkMonitor.verifyReachable()
        } catch let networkError as NetworkError {
            throw AuthenticationError.network(networkError)
        }
    }

    deinit {
        observationTask?.cancel()
    }
}
