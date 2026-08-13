//
//  MedicineErrorMessageTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 13/08/2026.
//

import XCTest
@testable import MediStock

final class MedicineErrorMessageTests: XCTestCase {
    func testLocalizedMessage_permissionDenied_localizesToFrench() {
        XCTAssertEqual(MedicineError.permissionDenied.localizedMessage, "Vous n'avez pas la permission de faire ça.")
    }

    func testLocalizedMessage_unknown_localizesToFrench() {
        XCTAssertEqual(MedicineError.unknown.localizedMessage, "Une erreur est survenue. Réessayez.")
    }

    func testLocalizedMessage_networkNotConnected_delegatesToNetworkError() {
        XCTAssertEqual(MedicineError.network(.notConnected).localizedMessage, "Pas de connexion internet. Réessayez.")
    }

    func testLocalizedMessage_networkServerUnreachable_delegatesToNetworkError() {
        XCTAssertEqual(MedicineError.network(.serverUnreachable).localizedMessage,
                       "Le serveur est injoignable. Réessayez dans un instant.")
    }
}
