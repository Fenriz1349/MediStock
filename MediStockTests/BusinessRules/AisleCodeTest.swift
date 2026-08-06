//
//  AisleCodeTest.swift
//  MediStockTests
//
//  Created by Julien Cotte on 06/08/2026.
//

import XCTest
@testable import MediStock

final class AisleCodeTest: XCTestCase {
    func testFormatPrependsLabelWhenProvided() {
        XCTAssertEqual(AisleCode.format(code: "AD56", aisleLabel: "Rayon"), "Rayon AD56")
    }

    func testFormatReturnsCodeAloneWhenLabelIsNil() {
        XCTAssertEqual(AisleCode.format(code: "AD56", aisleLabel: nil), "AD56")
    }

    func testStripLabelRemovesLabelCaseInsensitively() {
        XCTAssertEqual(AisleCode.stripLabel("Rayon", from: "rayon AD56"), "AD56")
    }

    func testStripLabelLeavesCodeUnchangedWhenLabelAbsent() {
        XCTAssertEqual(AisleCode.stripLabel("Rayon", from: "AD56"), "AD56")
    }

    func testAreInOrderComparesDigitRunsNumerically() {
        XCTAssertTrue(AisleCode.areInOrder("AD2", "AD10"))
        XCTAssertFalse(AisleCode.areInOrder("AD10", "AD2"))
    }

    func testAreInOrderFallsBackToTextComparisonWithoutDigits() {
        XCTAssertTrue(AisleCode.areInOrder("Entrée", "Sortie"))
    }
}
