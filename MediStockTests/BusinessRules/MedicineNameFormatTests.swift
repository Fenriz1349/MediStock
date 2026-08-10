//
//  MedicineNameFormatTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 10/08/2026.
//

import XCTest
@testable import MediStock

final class MedicineNameFormatTests: XCTestCase {
    func testCapitalizedUppercasesTheFirstLetterAndLowercasesTheRest() {
        XCTAssertEqual(MedicineNameFormat.capitalized("doliprane"), "Doliprane")
        XCTAssertEqual(MedicineNameFormat.capitalized("DOLIPRANE"), "Doliprane")
        XCTAssertEqual(MedicineNameFormat.capitalized("dOLIPRANE"), "Doliprane")
    }

    func testCapitalizedLeavesAnAlreadyCapitalizedNameUnchanged() {
        XCTAssertEqual(MedicineNameFormat.capitalized("Doliprane"), "Doliprane")
    }

    func testCapitalizedHandlesASingleCharacter() {
        XCTAssertEqual(MedicineNameFormat.capitalized("d"), "D")
    }

    func testCapitalizedReturnsEmptyStringUnchanged() {
        XCTAssertEqual(MedicineNameFormat.capitalized(""), "")
    }
}
