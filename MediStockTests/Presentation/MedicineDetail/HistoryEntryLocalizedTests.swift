//
//  HistoryEntryLocalizedTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 12/08/2026.
//

import XCTest
@testable import MediStock

final class HistoryEntryLocalizedTests: XCTestCase {
    func testAction_added_localizesToFrench() {
        let entry = TestHelper.makeHistoryEntry(action: "Added Doliprane")

        XCTAssertEqual(HistoryEntryLocalized(entry).action, "Ajout de Doliprane")
    }

    func testAction_updated_localizesToFrench() {
        let entry = TestHelper.makeHistoryEntry(action: "Updated Doliprane")

        XCTAssertEqual(HistoryEntryLocalized(entry).action, "Modification de Doliprane")
    }

    func testAction_stockIncreased_localizesToFrench() {
        let entry = TestHelper.makeHistoryEntry(action: "Increased stock of Doliprane by 5")

        XCTAssertEqual(HistoryEntryLocalized(entry).action, "Augmentation du stock de Doliprane de 5")
    }

    func testAction_stockDecreased_localizesToFrench() {
        let entry = TestHelper.makeHistoryEntry(action: "Decreased stock of Doliprane by 3")

        XCTAssertEqual(HistoryEntryLocalized(entry).action, "Diminution du stock de Doliprane de 3")
    }

    func testAction_unrecognizedFormat_fallsBackToRawString() {
        let entry = TestHelper.makeHistoryEntry(action: "Something unexpected")

        XCTAssertEqual(HistoryEntryLocalized(entry).action, "Something unexpected")
    }

    func testDetails_added_localizesToFrench() {
        let entry = TestHelper.makeHistoryEntry(details: "Added new medicine with initial stock of 42")

        XCTAssertEqual(HistoryEntryLocalized(entry).details, "Stock initial de 42")
    }

    func testDetails_updated_localizesToFrench() {
        let entry = TestHelper.makeHistoryEntry(details: "Updated medicine details")

        XCTAssertEqual(HistoryEntryLocalized(entry).details, "Détails mis à jour")
    }

    func testDetails_stockChanged_localizesToFrench() {
        let entry = TestHelper.makeHistoryEntry(details: "Stock changed from 10 to 15")

        XCTAssertEqual(HistoryEntryLocalized(entry).details, "Stock passé de 10 à 15")
    }

    func testDetails_unrecognizedFormat_fallsBackToRawString() {
        let entry = TestHelper.makeHistoryEntry(details: "Something unexpected")

        XCTAssertEqual(HistoryEntryLocalized(entry).details, "Something unexpected")
    }

    func testUser_anyEntry_passesThroughUnchanged() {
        let entry = TestHelper.makeHistoryEntry(user: "pharmacist@medistock.fr")

        XCTAssertEqual(HistoryEntryLocalized(entry).user, "pharmacist@medistock.fr")
    }
}
