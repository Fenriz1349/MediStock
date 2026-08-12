//
//  AuthenticationServicingDouble.swift
//  MediStockTests
//
//  Created by Julien Cotte on 12/08/2026.
//

import Foundation
@testable import MediStock

/// In-memory fake of `AuthenticationServicing` for testing, with a controllable session stream.
final class AuthenticationServicingDouble: AuthenticationServicing {
    enum Failure: Error {
        case generic
    }

    var currentUser: AppUser?
    var signInResult: Result<AppUser, Error> = .failure(Failure.generic)
    var signUpResult: Result<AppUser, Error> = .failure(Failure.generic)
    var signOutError: Error?
    var deleteAccountError: Error?

    private let sessionStream: AsyncStream<AppUser?>
    private let sessionContinuation: AsyncStream<AppUser?>.Continuation

    init() {
        var continuation: AsyncStream<AppUser?>.Continuation!
        sessionStream = AsyncStream { continuation = $0 }
        sessionContinuation = continuation
    }

    func observeSession() -> AsyncStream<AppUser?> {
        sessionStream
    }

    func emit(_ user: AppUser?) {
        sessionContinuation.yield(user)
    }

    func signUp(email: String, password: String) async throws -> AppUser {
        try signUpResult.get()
    }

    func signIn(email: String, password: String) async throws -> AppUser {
        try signInResult.get()
    }

    func signOut() throws {
        if let signOutError { throw signOutError }
    }

    func deleteAccount() async throws {
        if let deleteAccountError { throw deleteAccountError }
    }
}
