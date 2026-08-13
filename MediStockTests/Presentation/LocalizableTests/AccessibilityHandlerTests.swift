//
//  AccessibilityHandlerTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 13/08/2026.
//

import XCTest
@testable import MediStock

final class AccessibilityHandlerTests: XCTestCase {
    func testMedicineRowLabel_localizesToFrench() {
        let label = AccessibilityHandler.MedicineRow.label(name: "Doliprane", stock: 42)

        XCTAssertEqual(label, "Doliprane, stock de 42")
    }

    func testAisleRowLabel_singleMedicine_usesSingularWording() {
        let label = AccessibilityHandler.AisleRow.label(aisle: "Rayon AD56", medicineCount: 1)

        XCTAssertEqual(label, "Rayon AD56, 1 médicament")
    }

    func testAisleRowLabel_multipleMedicines_usesPluralWording() {
        let label = AccessibilityHandler.AisleRow.label(aisle: "Rayon AD56", medicineCount: 12)

        XCTAssertEqual(label, "Rayon AD56, 12 médicaments")
    }
}
