//
//  AisleCodeTest.swift
//  MediStockTests
//
//  Created by Julien Cotte on 06/08/2026.
//

import XCTest
@testable import MediStock

final class AisleCodeTest: XCTestCase {
    func testFormat_labelProvided_prependsLabel() {
        XCTAssertEqual(AisleCode.format(code: "AD56", aisleLabel: "Rayon"), "Rayon AD56")
    }

    func testFormat_labelNil_returnsCodeAlone() {
        XCTAssertEqual(AisleCode.format(code: "AD56", aisleLabel: nil), "AD56")
    }

    func testStripLabel_labelPresent_removesItCaseInsensitively() {
        XCTAssertEqual(AisleCode.stripLabel("Rayon", from: "rayon AD56"), "AD56")
    }

    func testStripLabel_labelAbsent_leavesCodeUnchanged() {
        XCTAssertEqual(AisleCode.stripLabel("Rayon", from: "AD56"), "AD56")
    }

    func testAreInOrder_digitRuns_comparesNumerically() {
        XCTAssertTrue(AisleCode.areInOrder("AD2", "AD10"))
        XCTAssertFalse(AisleCode.areInOrder("AD10", "AD2"))
    }

    func testAreInOrder_noDigits_fallsBackToTextComparison() {
        XCTAssertTrue(AisleCode.areInOrder("Entrée", "Sortie"))
    }
}
