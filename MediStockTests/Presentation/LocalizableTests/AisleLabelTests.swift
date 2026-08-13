//
//  AisleLabelTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 13/08/2026.
//

import XCTest
@testable import MediStock

final class AisleLabelTests: XCTestCase {
    func testLocalized_localizesToFrench() {
        XCTAssertEqual(AisleLabel.localized, "Rayon")
    }
}
