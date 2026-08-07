//
//  PasswordPolicyTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 07/08/2026.
//

import XCTest
@testable import MediStock

final class PasswordPolicyTests: XCTestCase {
    func testValidPasswordHasNoUnmetRequirements() {
        XCTAssertTrue(PasswordPolicy.unmetRequirements(for: "Abcdef1!").isEmpty)
        XCTAssertTrue(PasswordPolicy.isValid("Abcdef1!"))
    }

    func testEmptyPasswordFailsEveryRequirement() {
        XCTAssertEqual(PasswordPolicy.unmetRequirements(for: ""), Set(PasswordRequirement.allCases))
        XCTAssertFalse(PasswordPolicy.isValid(""))
    }

    func testTooShortPasswordFailsMinLength() {
        XCTAssertTrue(PasswordPolicy.unmetRequirements(for: "Ab1!").contains(.minLength))
    }

    func testMissingUppercaseFailsUppercaseOnly() {
        let unmet = PasswordPolicy.unmetRequirements(for: "abcdefg1!")
        XCTAssertTrue(unmet.contains(.uppercase))
        XCTAssertFalse(unmet.contains(.lowercase))
        XCTAssertFalse(unmet.contains(.digit))
        XCTAssertFalse(unmet.contains(.specialCharacter))
        XCTAssertFalse(unmet.contains(.minLength))
    }

    func testMissingLowercaseFailsLowercaseOnly() {
        XCTAssertEqual(PasswordPolicy.unmetRequirements(for: "ABCDEFG1!"), [.lowercase])
    }

    func testMissingDigitFailsDigitOnly() {
        XCTAssertEqual(PasswordPolicy.unmetRequirements(for: "Abcdefgh!"), [.digit])
    }

    func testMissingSpecialCharacterFailsSpecialCharacterOnly() {
        XCTAssertEqual(PasswordPolicy.unmetRequirements(for: "Abcdefg1"), [.specialCharacter])
    }

    func testIsValidFalseWhenAnySingleRequirementIsMissing() {
        XCTAssertFalse(PasswordPolicy.isValid("abcdefg1!")) // missing uppercase
        XCTAssertFalse(PasswordPolicy.isValid("Abcdefgh!")) // missing digit
        XCTAssertFalse(PasswordPolicy.isValid("Abcdefg1")) // missing special character
        XCTAssertFalse(PasswordPolicy.isValid("Ab1!")) // too short
    }
}
