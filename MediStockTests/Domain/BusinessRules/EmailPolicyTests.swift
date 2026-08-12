//
//  EmailPolicyTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 11/08/2026.
//

import XCTest
@testable import MediStock

final class EmailPolicyTests: XCTestCase {
    func testIsValid_plausibleAddress_returnsTrue() {
        XCTAssertTrue(EmailPolicy.isValid("test@example.com"))
    }

    func testIsValid_missingAtSign_returnsFalse() {
        XCTAssertFalse(EmailPolicy.isValid("test.example.com"))
    }

    func testIsValid_missingDomainDot_returnsFalse() {
        XCTAssertFalse(EmailPolicy.isValid("test@example"))
    }

    func testIsValid_emptyString_returnsFalse() {
        XCTAssertFalse(EmailPolicy.isValid(""))
    }

    func testIsValid_containsWhitespace_returnsFalse() {
        XCTAssertFalse(EmailPolicy.isValid("te st@example.com"))
    }
}
