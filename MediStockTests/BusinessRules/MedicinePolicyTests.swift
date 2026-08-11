//
//  MedicinePolicyTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 11/08/2026.
//

import XCTest
@testable import MediStock

final class MedicinePolicyTests: XCTestCase {
    func testIsValidName_atMinimumLength_returnsTrue() {
        XCTAssertTrue(MedicinePolicy.isValidName("Do"))
    }

    func testIsValidName_belowMinimumLength_returnsFalse() {
        XCTAssertFalse(MedicinePolicy.isValidName("D"))
    }

    func testIsValidName_emptyString_returnsFalse() {
        XCTAssertFalse(MedicinePolicy.isValidName(""))
    }

    func testIsValidName_onlyWhitespace_returnsFalse() {
        XCTAssertFalse(MedicinePolicy.isValidName("  "))
    }

    func testIsValidAisle_nonEmpty_returnsTrue() {
        XCTAssertTrue(MedicinePolicy.isValidAisle("AD56"))
    }

    func testIsValidAisle_emptyString_returnsFalse() {
        XCTAssertFalse(MedicinePolicy.isValidAisle(""))
    }

    func testIsValidAisle_onlyWhitespace_returnsFalse() {
        XCTAssertFalse(MedicinePolicy.isValidAisle("  "))
    }

    func testIsValidStock_positiveInteger_returnsTrue() {
        XCTAssertTrue(MedicinePolicy.isValidStock("10"))
    }

    func testIsValidStock_zero_returnsTrue() {
        XCTAssertTrue(MedicinePolicy.isValidStock("0"))
    }

    func testIsValidStock_negativeInteger_returnsFalse() {
        XCTAssertFalse(MedicinePolicy.isValidStock("-1"))
    }

    func testIsValidStock_nonNumeric_returnsFalse() {
        XCTAssertFalse(MedicinePolicy.isValidStock("abc"))
    }

    func testIsValidStock_emptyString_returnsFalse() {
        XCTAssertFalse(MedicinePolicy.isValidStock(""))
    }
}
