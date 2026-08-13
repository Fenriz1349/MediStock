//
//  AuthenticationErrorMessageTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 13/08/2026.
//

import XCTest
@testable import MediStock

final class AuthenticationErrorMessageTests: XCTestCase {
    func testLocalizedMessage_wrongCredentials_localizesToFrench() {
        XCTAssertEqual(AuthenticationError.wrongCredentials.localizedMessage, "E-mail ou mot de passe incorrect.")
    }

    func testLocalizedMessage_emailAlreadyInUse_localizesToFrench() {
        XCTAssertEqual(AuthenticationError.emailAlreadyInUse.localizedMessage,
                       "Un compte existe déjà avec cette adresse e-mail.")
    }

    func testLocalizedMessage_weakPassword_localizesToFrench() {
        XCTAssertEqual(AuthenticationError.weakPassword.localizedMessage, "Ce mot de passe est trop faible.")
    }

    func testLocalizedMessage_requiresRecentLogin_localizesToFrench() {
        XCTAssertEqual(AuthenticationError.requiresRecentLogin.localizedMessage,
                       "Déconnectez-vous puis reconnectez-vous avant de réessayer.")
    }

    func testLocalizedMessage_unknown_localizesToFrench() {
        XCTAssertEqual(AuthenticationError.unknown.localizedMessage, "Une erreur est survenue. Réessayez.")
    }

    func testLocalizedMessage_networkNotConnected_delegatesToNetworkError() {
        XCTAssertEqual(AuthenticationError.network(.notConnected).localizedMessage,
                       "Pas de connexion internet. Réessayez.")
    }

    func testLocalizedMessage_networkServerUnreachable_delegatesToNetworkError() {
        XCTAssertEqual(AuthenticationError.network(.serverUnreachable).localizedMessage,
                       "Le serveur est injoignable. Réessayez dans un instant.")
    }
}
