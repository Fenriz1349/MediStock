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
        let service = AuthenticationServicingDouble()
        let user = TestHelper.makeAppUser()
        service.signInResult = .success(user)
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)

        await viewModel.signIn(email: "test@example.com", password: "password")

        XCTAssertEqual(viewModel.session, user)
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testSignIn_inFlight_togglesIsLoading() async {
        let service = AuthenticationServicingDouble()
        service.signInResult = .success(TestHelper.makeAppUser())
        let networkMonitor = NetworkMonitoringDouble()
        networkMonitor.verifyReachableDelayNanoseconds = 50_000_000
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service,
                                                                networkMonitor: networkMonitor)
        XCTAssertFalse(viewModel.isLoading)

        let task = Task { await viewModel.signIn(email: "test@example.com", password: "password") }
        await TestHelper.waitUntil { viewModel.isLoading }
        XCTAssertTrue(viewModel.isLoading)

        await task.value

        XCTAssertFalse(viewModel.isLoading)
    }

    @MainActor
    func testSignIn_failure_keepsSessionNilAndSetsTypedError() async {
        let service = AuthenticationServicingDouble()
        service.signInResult = .failure(AuthenticationError.wrongCredentials)
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)

        await viewModel.signIn(email: "test@example.com", password: "wrong")

        XCTAssertNil(viewModel.session)
        XCTAssertEqual(viewModel.error, .wrongCredentials)
    }

    @MainActor
    func testSignIn_networkUnreachable_skipsService() async {
        let service = AuthenticationServicingDouble()
        let networkMonitor = NetworkMonitoringDouble()
        networkMonitor.verifyReachableError = .notConnected
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service,
                                                                networkMonitor: networkMonitor)

        await viewModel.signIn(email: "test@example.com", password: "password")

        XCTAssertEqual(viewModel.error, .network(.notConnected))
        XCTAssertNil(viewModel.session)
    }

    @MainActor
    func testSignIn_untypedError_setsUnknown() async {
        let service = AuthenticationServicingDouble()
        service.signInResult = .failure(AuthenticationServicingDouble.Failure.generic)
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)

        await viewModel.signIn(email: "test@example.com", password: "wrong")

        XCTAssertEqual(viewModel.error, .unknown)
    }

    @MainActor
    func testSignUp_success_updatesSession() async {
        let service = AuthenticationServicingDouble()
        let user = TestHelper.makeAppUser(uid: "456", email: "new@example.com")
        service.signUpResult = .success(user)
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)

        await viewModel.signUp(email: "new@example.com", password: "password")

        XCTAssertEqual(viewModel.session, user)
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testSignUp_failure_setsTypedError() async {
        let service = AuthenticationServicingDouble()
        service.signUpResult = .failure(AuthenticationError.emailAlreadyInUse)
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)

        await viewModel.signUp(email: "new@example.com", password: "password")

        XCTAssertEqual(viewModel.error, .emailAlreadyInUse)
    }

    @MainActor
    func testSignOut_success_clearsSession() async {
        let service = AuthenticationServicingDouble()
        service.signInResult = .success(TestHelper.makeAppUser())
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)
        await viewModel.signIn(email: "test@example.com", password: "password")

        viewModel.signOut()

        XCTAssertNil(viewModel.session)
    }

    @MainActor
    func testSignOut_failure_setsTypedError() async {
        let service = AuthenticationServicingDouble()
        service.signOutError = AuthenticationError.unknown
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)

        viewModel.signOut()

        XCTAssertEqual(viewModel.error, .unknown)
    }

    @MainActor
    func testDeleteAccount_success_clearsSession() async {
        let service = AuthenticationServicingDouble()
        service.signInResult = .success(TestHelper.makeAppUser())
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)
        await viewModel.signIn(email: "test@example.com", password: "password")

        await viewModel.deleteAccount()

        XCTAssertNil(viewModel.session)
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testDeleteAccount_failure_setsTypedErrorAndKeepsSession() async {
        let service = AuthenticationServicingDouble()
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
    func testError_newAttempt_resets() async {
        let service = AuthenticationServicingDouble()
        service.signInResult = .failure(AuthenticationError.wrongCredentials)
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)
        await viewModel.signIn(email: "test@example.com", password: "wrong")
        XCTAssertEqual(viewModel.error, .wrongCredentials)

        service.signInResult = .success(TestHelper.makeAppUser())
        await viewModel.signIn(email: "test@example.com", password: "password")

        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testListen_sessionStreamEmits_reflectsSession() async {
        let service = AuthenticationServicingDouble()
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)
        let user = TestHelper.makeAppUser(uid: "789", email: "stream@example.com")

        viewModel.listen()
        service.emit(user)
        await TestHelper.waitUntil { viewModel.session != nil }

        XCTAssertEqual(viewModel.session, user)
    }

    @MainActor
    func testIsConnected_afterInit_reflectsNetworkMonitor() {
        let networkMonitor = NetworkMonitoringDouble()
        networkMonitor.isConnected = false
        let viewModel = TestHelper.makeAuthenticationViewModel(networkMonitor: networkMonitor)

        XCTAssertFalse(viewModel.isConnected)
    }

    @MainActor
    func testListenConnectivity_connectivityStreamEmits_updatesIsConnected() async {
        let networkMonitor = NetworkMonitoringDouble(isConnected: false)
        let viewModel = TestHelper.makeAuthenticationViewModel(networkMonitor: networkMonitor)
        XCTAssertFalse(viewModel.isConnected)

        viewModel.listenConnectivity()
        networkMonitor.emit(true)
        await TestHelper.waitUntil { viewModel.isConnected }

        XCTAssertTrue(viewModel.isConnected)
    }
}
