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
    func testSignIn_success_updatesSession() async {
        let service = MockAuthenticationServicing()
        let user = TestHelper.makeAppUser()
        service.signInResult = .success(user)
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)

        viewModel.email = "test@example.com"
        viewModel.password = "password"
        await viewModel.signIn()

        XCTAssertEqual(viewModel.session, user)
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testSignIn_inFlight_togglesIsLoading() async {
        let service = MockAuthenticationServicing()
        service.signInResult = .success(TestHelper.makeAppUser())
        let networkMonitor = MockNetworkMonitoring()
        networkMonitor.verifyReachableDelayNanoseconds = 50_000_000
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service,
                                                                networkMonitor: networkMonitor)
        XCTAssertFalse(viewModel.isLoading)

        viewModel.email = "test@example.com"
        viewModel.password = "password"
        let task = Task { await viewModel.signIn() }
        await TestHelper.waitUntil { viewModel.isLoading }
        XCTAssertTrue(viewModel.isLoading)

        await task.value

        XCTAssertFalse(viewModel.isLoading)
    }

    @MainActor
    func testSignIn_failure_keepsSessionNilAndSetsTypedError() async {
        let service = MockAuthenticationServicing()
        service.signInResult = .failure(AuthenticationError.wrongCredentials)
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)

        viewModel.email = "test@example.com"
        viewModel.password = "wrong"
        await viewModel.signIn()

        XCTAssertNil(viewModel.session)
        XCTAssertEqual(viewModel.error, .wrongCredentials)
    }

    @MainActor
    func testSignIn_networkUnreachable_skipsService() async {
        let service = MockAuthenticationServicing()
        let networkMonitor = MockNetworkMonitoring()
        networkMonitor.verifyReachableError = .notConnected
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service,
                                                                networkMonitor: networkMonitor)

        viewModel.email = "test@example.com"
        viewModel.password = "password"
        await viewModel.signIn()

        XCTAssertEqual(viewModel.error, .network(.notConnected))
        XCTAssertNil(viewModel.session)
    }

    @MainActor
    func testSignIn_untypedError_setsUnknown() async {
        let service = MockAuthenticationServicing()
        service.signInResult = .failure(MockAuthenticationServicing.Failure.generic)
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)

        viewModel.email = "test@example.com"
        viewModel.password = "wrong"
        await viewModel.signIn()

        XCTAssertEqual(viewModel.error, .unknown)
    }

    @MainActor
    func testSignUp_success_updatesSession() async {
        let service = MockAuthenticationServicing()
        let user = TestHelper.makeAppUser(uid: "456", email: "new@example.com")
        service.signUpResult = .success(user)
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)

        viewModel.email = "new@example.com"
        viewModel.password = "password"
        await viewModel.signUp()

        XCTAssertEqual(viewModel.session, user)
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testSignUp_failure_setsTypedError() async {
        let service = MockAuthenticationServicing()
        service.signUpResult = .failure(AuthenticationError.emailAlreadyInUse)
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)

        viewModel.email = "new@example.com"
        viewModel.password = "password"
        await viewModel.signUp()

        XCTAssertEqual(viewModel.error, .emailAlreadyInUse)
    }

    @MainActor
    func testSignOut_success_clearsSession() async {
        let service = MockAuthenticationServicing()
        service.signInResult = .success(TestHelper.makeAppUser())
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)
        viewModel.email = "test@example.com"
        viewModel.password = "password"
        await viewModel.signIn()

        viewModel.signOut()

        XCTAssertNil(viewModel.session)
    }

    @MainActor
    func testSignOut_failure_setsTypedError() async {
        let service = MockAuthenticationServicing()
        service.signOutError = AuthenticationError.unknown
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)

        viewModel.signOut()

        XCTAssertEqual(viewModel.error, .unknown)
    }

    @MainActor
    func testDeleteAccount_success_clearsSession() async {
        let service = MockAuthenticationServicing()
        service.signInResult = .success(TestHelper.makeAppUser())
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)
        viewModel.email = "test@example.com"
        viewModel.password = "password"
        await viewModel.signIn()

        await viewModel.deleteAccount()

        XCTAssertNil(viewModel.session)
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testDeleteAccount_failure_setsTypedErrorAndKeepsSession() async {
        let service = MockAuthenticationServicing()
        let user = TestHelper.makeAppUser()
        service.signInResult = .success(user)
        service.deleteAccountError = AuthenticationError.requiresRecentLogin
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)
        viewModel.email = "test@example.com"
        viewModel.password = "password"
        await viewModel.signIn()

        await viewModel.deleteAccount()

        XCTAssertEqual(viewModel.session, user)
        XCTAssertEqual(viewModel.error, .requiresRecentLogin)
    }

    @MainActor
    func testError_newAttempt_resets() async {
        let service = MockAuthenticationServicing()
        service.signInResult = .failure(AuthenticationError.wrongCredentials)
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)
        viewModel.email = "test@example.com"
        viewModel.password = "wrong"
        await viewModel.signIn()
        XCTAssertEqual(viewModel.error, .wrongCredentials)

        service.signInResult = .success(TestHelper.makeAppUser())
        viewModel.email = "test@example.com"
        viewModel.password = "password"
        await viewModel.signIn()

        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testListen_sessionStreamEmits_reflectsSession() async {
        let service = MockAuthenticationServicing()
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)
        let user = TestHelper.makeAppUser(uid: "789", email: "stream@example.com")

        viewModel.listen()
        service.emit(user)
        await TestHelper.waitUntil { viewModel.session != nil }

        XCTAssertEqual(viewModel.session, user)
    }

    @MainActor
    func testIsConnected_afterInit_reflectsNetworkMonitor() {
        let networkMonitor = MockNetworkMonitoring()
        networkMonitor.isConnected = false
        let viewModel = TestHelper.makeAuthenticationViewModel(networkMonitor: networkMonitor)

        XCTAssertFalse(viewModel.isConnected)
    }

    @MainActor
    func testListenConnectivity_connectivityStreamEmits_updatesIsConnected() async {
        let networkMonitor = MockNetworkMonitoring(isConnected: false)
        let viewModel = TestHelper.makeAuthenticationViewModel(networkMonitor: networkMonitor)
        XCTAssertFalse(viewModel.isConnected)

        viewModel.listenConnectivity()
        networkMonitor.emit(true)
        await TestHelper.waitUntil { viewModel.isConnected }

        XCTAssertTrue(viewModel.isConnected)
    }
}

/// In-memory fake of `AuthenticationServicing` for testing, with a controllable session stream.
final class MockAuthenticationServicing: AuthenticationServicing {
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
