//
//  MediStockUITests.swift
//  MediStockUITests
//
//  Created by Vincent Saluzzo on 28/05/2024.
//

import XCTest

/// End-to-end interface test covering one full user journey.
/// **Before running:** start the Firebase Local Emulator Suite locally (`firebase emulators:start`).
/// The app is launched with the `UI-TESTING` argument, which points Auth/Firestore at the emulator.
/// Assumes the simulator's language is French (the app's source language) — several assertions match localized text.
final class MediStockUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCompleteUserJourney() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
        app.launch()

        // Lowercased: Firebase Auth normalizes stored emails to lowercase, and `UUID().uuidString`
        // is uppercase hex — comparing against the displayed email later would otherwise mismatch.
        let email = "uitest-\(UUID().uuidString.prefix(8))@medistock-test.fr".lowercased()
        let password = "TestPassword1!"
        // Typed with a capital "T", to verify end-to-end that `MedicineNameFormat.capitalized(_:)`
        // actually gets applied through the real form → save → display pipeline, not just in
        // isolation the way `MedicineNameFormatTests` already covers it.
        let typedMedicineName = "Doliprane Test"
        let normalizedMedicineName = "Doliprane test"
        let aisle = "AD56"

        // Sign up.
        let emailField = app.textFields["auth.emailField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        emailField.tap()
        emailField.typeText(email)

        let passwordField = app.secureTextFields["auth.passwordField"]
        passwordField.tap()
        passwordField.typeText(password)

        app.buttons["auth.signUpButton"].tap()

        // Add a medicine directly from the aisle list (the default tab, no need to switch tabs first).
        let addFromAisleList = app.buttons["aisleList.addButton"]
        XCTAssertTrue(addFromAisleList.waitForExistence(timeout: 10))
        addFromAisleList.tap()

        let nameField = app.textFields["medicineForm.nameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText(typedMedicineName)

        let aisleField = app.textFields["medicineForm.aisleField"]
        aisleField.tap()
        aisleField.typeText(aisle)

        let stockField = app.textFields["medicineForm.stockField"]
        stockField.tap()
        stockField.typeText("10")

        app.buttons["addMedicine.saveButton"].tap()

        // The aisle now exists in the aisle list.
        let aisleRow = app.buttons["aisleRow.\(aisle)"]
        XCTAssertTrue(aisleRow.waitForExistence(timeout: 5))
        aisleRow.tap()

        // The medicine is inside that aisle, with the stock as entered.
        // Found by its normalized name — "Doliprane Test" was typed, "Doliprane test" is what's stored.
        let medicineRowInAisle = app.buttons["medicineRow.\(normalizedMedicineName)"]
        XCTAssertTrue(medicineRowInAisle.waitForExistence(timeout: 5))
        XCTAssertTrue(medicineRowInAisle.label.contains("10"))
        medicineRowInAisle.tap()

        // Increase, then verify a history entry was recorded.
        let increaseButton = app.buttons["medicineDetail.increaseButton"]
        XCTAssertTrue(increaseButton.waitForExistence(timeout: 5))
        increaseButton.tap()

        let increaseLog = app.otherElements.containing(
            NSPredicate(format: "label CONTAINS %@", "Augmentation")
        ).firstMatch
        XCTAssertTrue(increaseLog.waitForExistence(timeout: 5))

        // Switch to the full catalog tab — same medicine, now at stock 11.
        // Matched by its SF Symbol name: SwiftUI derives the tab's identifier from the `Image` inside
        // `.tabItem`, not from an `.accessibilityIdentifier` on the tab's text (see `MainTabView`).
        app.tabBars.buttons["square.grid.2x2"].tap()

        let medicineRowInCatalog = app.buttons["medicineRow.\(normalizedMedicineName)"]
        XCTAssertTrue(medicineRowInCatalog.waitForExistence(timeout: 5))
        XCTAssertTrue(medicineRowInCatalog.label.contains("11"))
        medicineRowInCatalog.tap()

        // Decrease, then verify a history entry was recorded.
        let decreaseButton = app.buttons["medicineDetail.decreaseButton"]
        XCTAssertTrue(decreaseButton.waitForExistence(timeout: 5))
        decreaseButton.tap()

        let decreaseLog = app.otherElements.containing(
            NSPredicate(format: "label CONTAINS %@", "Diminution")
        ).firstMatch
        XCTAssertTrue(decreaseLog.waitForExistence(timeout: 5))

        // Delete the medicine.
        app.buttons["medicineDetail.deleteButton"].tap()
        app.alerts.buttons["Supprimer"].tap()

        // Delete the account, closing the loop so no test account lingers in the emulator.
        app.tabBars.buttons["person.circle"].tap()

        let emailLabel = app.staticTexts["user.emailLabel"]
        XCTAssertTrue(emailLabel.waitForExistence(timeout: 5))
        XCTAssertEqual(emailLabel.label, email)

        app.buttons["user.deleteAccountButton"].tap()
        app.alerts.buttons["Supprimer"].tap()

        let emailFieldAfterDeletion = app.textFields["auth.emailField"]
        XCTAssertTrue(emailFieldAfterDeletion.waitForExistence(timeout: 10))
    }
}
