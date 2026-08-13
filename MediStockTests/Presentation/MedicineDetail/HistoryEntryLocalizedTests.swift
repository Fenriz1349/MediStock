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

    func testDetails_nameChangedOnly_localizesToFrench() {
        let entry = TestHelper.makeHistoryEntry(details: "name changed from Doliprane to Dafalgan")

        XCTAssertEqual(HistoryEntryLocalized(entry).details, "Nom passé de Doliprane à Dafalgan")
    }

    func testDetails_aisleChangedOnly_localizesToFrench() {
        let entry = TestHelper.makeHistoryEntry(details: "aisle changed from AD56 to AD10")

        XCTAssertEqual(HistoryEntryLocalized(entry).details, "Rayon passé de AD56 à AD10")
    }

    func testDetails_nameAndAisleChanged_localizesBothClauses() {
        let entry = TestHelper.makeHistoryEntry(
            details: "name changed from Doliprane to Dafalgan, aisle changed from AD56 to AD10"
        )

        XCTAssertEqual(HistoryEntryLocalized(entry).details,
                       "Nom passé de Doliprane à Dafalgan, Rayon passé de AD56 à AD10")
    }

    func testUser_anyEntry_passesThroughUnchanged() {
        let entry = TestHelper.makeHistoryEntry(user: "pharmacist@medistock.fr")

        XCTAssertEqual(HistoryEntryLocalized(entry).user, "pharmacist@medistock.fr")
    }
}
