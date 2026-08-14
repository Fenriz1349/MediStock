//
//  AuthenticationIntegrationTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 14/08/2026.
//

import XCTest
@testable import MediStock

final class AuthenticationIntegrationTests: XCTestCase {
    @MainActor
    func testScenario_signUpThenSignOutThenWrongPasswordThenCorrectPassword() async {
        let service = AuthenticationServicingDouble()
        let user = TestHelper.makeAppUser(email: "test@example.com")
        service.signUpResult = .success(user)
        let viewModel = TestHelper.makeAuthenticationViewModel(authenticationService: service)

        viewModel.email = "test@example.com"
        viewModel.password = "Password1!"
        await viewModel.signUp()
        XCTAssertEqual(viewModel.session, user)

        viewModel.signOut()
        XCTAssertNil(viewModel.session)

        service.signInResult = .failure(AuthenticationError.wrongCredentials)
        viewModel.password = "wrongPassword"
        await viewModel.signIn()
        XCTAssertNil(viewModel.session)
        XCTAssertEqual(viewModel.error, .wrongCredentials)

        service.signInResult = .success(user)
        viewModel.password = "Password1!"
        await viewModel.signIn()
        XCTAssertEqual(viewModel.session, user)
        XCTAssertNil(viewModel.error)
    }
}
