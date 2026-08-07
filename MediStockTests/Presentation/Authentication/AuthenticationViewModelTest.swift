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
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)

        await viewModel.signIn(email: "test@example.com", password: "password")

        XCTAssertEqual(viewModel.session, user)
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testSignInFailureKeepsSessionNilAndSetsTypedError() async {
        let service = MockAuthenticationServicing()
        service.signInResult = .failure(AuthenticationError.wrongCredentials)
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)

        await viewModel.signIn(email: "test@example.com", password: "wrong")

        XCTAssertNil(viewModel.session)
        XCTAssertEqual(viewModel.error, .wrongCredentials)
    }

    @MainActor
    func testSignInFailureWithUntypedErrorSetsUnknown() async {
        let service = MockAuthenticationServicing()
        service.signInResult = .failure(MockAuthenticationServicing.Failure.generic)
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)

        await viewModel.signIn(email: "test@example.com", password: "wrong")

        XCTAssertEqual(viewModel.error, .unknown)
    }

    @MainActor
    func testSignUpSuccessUpdatesSession() async {
        let service = MockAuthenticationServicing()
        let user = TestHelper.makeAppUser(uid: "456", email: "new@example.com")
        service.signUpResult = .success(user)
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)

        await viewModel.signUp(email: "new@example.com", password: "password")

        XCTAssertEqual(viewModel.session, user)
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testSignUpFailureSetsTypedError() async {
        let service = MockAuthenticationServicing()
        service.signUpResult = .failure(AuthenticationError.emailAlreadyInUse)
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)

        await viewModel.signUp(email: "new@example.com", password: "password")

        XCTAssertEqual(viewModel.error, .emailAlreadyInUse)
    }

    @MainActor
    func testSignOutClearsSession() async {
        let service = MockAuthenticationServicing()
        service.signInResult = .success(TestHelper.makeAppUser())
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)
        await viewModel.signIn(email: "test@example.com", password: "password")

        viewModel.signOut()

        XCTAssertNil(viewModel.session)
    }

    @MainActor
    func testSignOutFailureSetsTypedError() async {
        let service = MockAuthenticationServicing()
        service.signOutError = AuthenticationError.unknown
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)

        viewModel.signOut()

        XCTAssertEqual(viewModel.error, .unknown)
    }

    @MainActor
    func testDeleteAccountSuccessClearsSession() async {
        let service = MockAuthenticationServicing()
        service.signInResult = .success(TestHelper.makeAppUser())
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)
        await viewModel.signIn(email: "test@example.com", password: "password")

        await viewModel.deleteAccount()

        XCTAssertNil(viewModel.session)
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testDeleteAccountFailureSetsTypedErrorAndKeepsSession() async {
        let service = MockAuthenticationServicing()
        let user = TestHelper.makeAppUser()
        service.signInResult = .success(user)
        service.deleteAccountError = AuthenticationError.requiresRecentLogin
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)
        await viewModel.signIn(email: "test@example.com", password: "password")

        await viewModel.deleteAccount()

        XCTAssertEqual(viewModel.session, user)
        XCTAssertEqual(viewModel.error, .requiresRecentLogin)
    }

    @MainActor
    func testErrorResetsOnNewAttempt() async {
        let service = MockAuthenticationServicing()
        service.signInResult = .failure(AuthenticationError.wrongCredentials)
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)
        await viewModel.signIn(email: "test@example.com", password: "wrong")
        XCTAssertEqual(viewModel.error, .wrongCredentials)

        service.signInResult = .success(TestHelper.makeAppUser())
        await viewModel.signIn(email: "test@example.com", password: "password")

        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testListenReflectsSessionStream() async {
        let service = MockAuthenticationServicing()
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)
        let user = TestHelper.makeAppUser(uid: "789", email: "stream@example.com")

        viewModel.listen()
        service.emit(user)
        await TestHelper.waitUntil { viewModel.session != nil }

        XCTAssertEqual(viewModel.session, user)
    }
}

/// In-memory fake of `AuthenticationServicing` for testing, with a controllable session stream.
final class MockAuthenticationServicing: AuthenticationServicing {
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
