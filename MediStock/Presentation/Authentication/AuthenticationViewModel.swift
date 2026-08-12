//
//  AuthenticationViewModel.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import Foundation
import CustomTextFields

/// Presentation-layer state and actions for the authentication screen and app-wide session.
@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published private(set) var session: AppUser?
    /// Reset to `nil` at the start of every action, set again on failure. The View turns it into a toast.
    @Published private(set) var error: AuthenticationError?
    @Published private(set) var isLoading = false
    /// Live mirror of `networkMonitor.observeConnectivity()`, checked before a session/cache exists.
    @Published private(set) var isConnected: Bool

    @Published var email = ""
    @Published var password = ""
    @Published var emailState: ValidationState = .neutral
    @Published var passwordState: ValidationState = .neutral

    var unmetPasswordRequirements: Set<PasswordRequirement> {
        PasswordPolicy.unmetRequirements(for: password)
    }

    /// Re-checks the raw `email`/`password` directly, not `emailState`/`passwordState`.
    /// Those only update on focus loss, which the last field in the form may never trigger.
    var isFormValid: Bool {
        EmailPolicy.isValid(email) && unmetPasswordRequirements.isEmpty
    }

    private let authenticationService: AuthenticationServicing
    private let networkMonitor: NetworkMonitoring
    private var observationTask: Task<Void, Never>?
    private var connectivityTask: Task<Void, Never>?

    /// - Parameters:
    ///   - authenticationService: Domain-level auth abstraction, kept behind a protocol.
    ///   - networkMonitor: Checked before every write. See `verifyNetworkReachable()`.
    init(authenticationService: AuthenticationServicing, networkMonitor: NetworkMonitoring) {
        self.authenticationService = authenticationService
        self.networkMonitor = networkMonitor
        self.isConnected = networkMonitor.isConnected
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

    /// Starts observing live connectivity. Call once when the app appears.
    func listenConnectivity() {
        connectivityTask?.cancel()
        connectivityTask = Task { [weak self] in
            guard let stream = self?.networkMonitor.observeConnectivity() else { return }
            for await connected in stream {
                self?.isConnected = connected
            }
        }
    }

    /// Signs in with `email`/`password` and updates `session` on success.
    func signIn() async {
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

    /// Creates a new account with `email`/`password` and updates `session` on success.
    func signUp() async {
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

    /// Signs out locally. Use `deleteAccount()` to remove the account itself (App Store 5.1.1(v)).
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
    /// The View confirms with the user before calling this.
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
        connectivityTask?.cancel()
    }
}
