//
//  PasswordRequirementLabelTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 13/08/2026.
//

import XCTest
@testable import MediStock

final class PasswordRequirementLabelTests: XCTestCase {
    func testLocalizedDescription_minLength_localizesToFrench() {
        XCTAssertEqual(PasswordRequirement.minLength.localizedDescription, "8 caractères minimum")
    }

    func testLocalizedDescription_uppercase_localizesToFrench() {
        XCTAssertEqual(PasswordRequirement.uppercase.localizedDescription, "Une majuscule")
    }

    func testLocalizedDescription_lowercase_localizesToFrench() {
        XCTAssertEqual(PasswordRequirement.lowercase.localizedDescription, "Une minuscule")
    }

    func testLocalizedDescription_digit_localizesToFrench() {
        XCTAssertEqual(PasswordRequirement.digit.localizedDescription, "Un chiffre")
    }

    func testLocalizedDescription_specialCharacter_localizesToFrench() {
        XCTAssertEqual(PasswordRequirement.specialCharacter.localizedDescription, "Un caractère spécial")
    }
}
