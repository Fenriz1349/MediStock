//
//  PasswordPolicyTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 07/08/2026.
//

import XCTest
@testable import MediStock

final class PasswordPolicyTests: XCTestCase {
    func testUnmetRequirements_validPassword_returnsEmpty() {
        XCTAssertTrue(PasswordPolicy.unmetRequirements(for: "Abcdef1!").isEmpty)
        XCTAssertTrue(PasswordPolicy.isValid("Abcdef1!"))
    }

    func testUnmetRequirements_emptyPassword_returnsAll() {
        XCTAssertEqual(PasswordPolicy.unmetRequirements(for: ""), Set(PasswordRequirement.allCases))
        XCTAssertFalse(PasswordPolicy.isValid(""))
    }

    func testUnmetRequirements_tooShort_containsMinLength() {
        XCTAssertTrue(PasswordPolicy.unmetRequirements(for: "Ab1!").contains(.minLength))
    }

    func testUnmetRequirements_missingUppercase_containsUppercaseOnly() {
        let unmet = PasswordPolicy.unmetRequirements(for: "abcdefg1!")
        XCTAssertTrue(unmet.contains(.uppercase))
        XCTAssertFalse(unmet.contains(.lowercase))
        XCTAssertFalse(unmet.contains(.digit))
        XCTAssertFalse(unmet.contains(.specialCharacter))
        XCTAssertFalse(unmet.contains(.minLength))
    }

    func testUnmetRequirements_missingLowercase_containsLowercaseOnly() {
        XCTAssertEqual(PasswordPolicy.unmetRequirements(for: "ABCDEFG1!"), [.lowercase])
    }

    func testUnmetRequirements_missingDigit_containsDigitOnly() {
        XCTAssertEqual(PasswordPolicy.unmetRequirements(for: "Abcdefgh!"), [.digit])
    }

    func testUnmetRequirements_missingSpecialCharacter_containsSpecialCharacterOnly() {
        XCTAssertEqual(PasswordPolicy.unmetRequirements(for: "Abcdefg1"), [.specialCharacter])
    }

    func testIsValid_requirementMissing_returnsFalse() {
        XCTAssertFalse(PasswordPolicy.isValid("abcdefg1!")) // missing uppercase
        XCTAssertFalse(PasswordPolicy.isValid("Abcdefgh!")) // missing digit
        XCTAssertFalse(PasswordPolicy.isValid("Abcdefg1")) // missing special character
        XCTAssertFalse(PasswordPolicy.isValid("Ab1!")) // too short
    }
}
