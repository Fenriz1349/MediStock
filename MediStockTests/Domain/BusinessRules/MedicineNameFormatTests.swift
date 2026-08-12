//
//  MedicineNameFormatTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 10/08/2026.
//

import XCTest
@testable import MediStock

final class MedicineNameFormatTests: XCTestCase {
    func testCapitalized_mixedCase_uppercasesFirstLowercasesRest() {
        XCTAssertEqual(MedicineNameFormat.capitalized("doliprane"), "Doliprane")
        XCTAssertEqual(MedicineNameFormat.capitalized("DOLIPRANE"), "Doliprane")
        XCTAssertEqual(MedicineNameFormat.capitalized("dOLIPRANE"), "Doliprane")
    }

    func testCapitalized_alreadyCapitalized_leavesUnchanged() {
        XCTAssertEqual(MedicineNameFormat.capitalized("Doliprane"), "Doliprane")
    }

    func testCapitalized_singleCharacter_uppercasesIt() {
        XCTAssertEqual(MedicineNameFormat.capitalized("d"), "D")
    }

    func testCapitalized_emptyString_returnsUnchanged() {
        XCTAssertEqual(MedicineNameFormat.capitalized(""), "")
    }
}
