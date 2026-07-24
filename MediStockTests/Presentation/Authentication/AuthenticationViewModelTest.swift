//
//  AuthenticationViewModelTest.swift
//  MediStockTests
//
//  Created by Julien Cotte on 24/07/2026.
//

import XCTest
@testable import MediStock

final class AuthenticationViewModelTest: XCTestCase {
    @MainActor
    func testSignInSuccessUpdatesSession() async {
        let service = MockAuthenticationServicing()
        let user = TestHelper.makeAppUser()
        service.signInResult = .success(user)
        let viewModel = AuthenticationViewModel(authenticationService: service)

        await viewModel.signIn(email: "test@example.com", password: "password")

        XCTAssertEqual(viewModel.session, user)
    }

    @MainActor
    func testSignInFailureKeepsSessionNil() async {
        let service = MockAuthenticationServicing()
        service.signInResult = .failure(MockAuthenticationServicing.Failure.generic)
        let viewModel = AuthenticationViewModel(authenticationService: service)

        await viewModel.signIn(email: "test@example.com", password: "wrong")

        XCTAssertNil(viewModel.session)
    }

    @MainActor
    func testSignUpSuccessUpdatesSession() async {
        let service = MockAuthenticationServicing()
        let user = TestHelper.makeAppUser(uid: "456", email: "new@example.com")
        service.signUpResult = .success(user)
        let viewModel = AuthenticationViewModel(authenticationService: service)

        await viewModel.signUp(email: "new@example.com", password: "password")

        XCTAssertEqual(viewModel.session, user)
    }

    @MainActor
    func testSignOutClearsSession() async {
        let service = MockAuthenticationServicing()
        service.signInResult = .success(TestHelper.makeAppUser())
        let viewModel = AuthenticationViewModel(authenticationService: service)
        await viewModel.signIn(email: "test@example.com", password: "password")

        viewModel.signOut()

        XCTAssertNil(viewModel.session)
    }

    @MainActor
    func testListenReflectsSessionStream() async {
        let service = MockAuthenticationServicing()
        let viewModel = AuthenticationViewModel(authenticationService: service)
        let user = TestHelper.makeAppUser(uid: "789", email: "stream@example.com")

        viewModel.listen()
        service.emit(user)
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(viewModel.session, user)
    }
}

/// In-memory fake of `AuthenticationServicing` for testing, with a controllable session stream.
private final class MockAuthenticationServicing: AuthenticationServicing {
    enum Failure: Error {
        case generic
    }

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
