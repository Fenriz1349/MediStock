//
//  MedicineFormIntegrationTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 14/08/2026.
//

import XCTest
@testable import MediStock

final class MedicineFormIntegrationTests: XCTestCase {
    @MainActor
    func testScenario_createThenEdit_recordsAdditionThenUpdateWithPreviousValues() async {
        let medicineStore = MedicineStoringDouble()
        let historyStore = HistoryStoringDouble()
        let createViewModel = TestHelper.makeMedicineFormViewModel(medicineStore: medicineStore,
                                                                    historyStore: historyStore)
        createViewModel.name = "Doliprane"
        createViewModel.stockText = "10"

        let created = await createViewModel.save(cleanedAisle: "AD56")
        guard let created else {
            XCTFail("Expected the medicine to be created")
            return
        }

        let editViewModel = TestHelper.makeMedicineFormViewModel(existingMedicine: created,
                                                                  medicineStore: medicineStore,
                                                                  historyStore: historyStore)
        editViewModel.name = "Dafalgan"
        _ = await editViewModel.save(cleanedAisle: "AD10")

        XCTAssertEqual(historyStore.addedMedicines.count, 1)
        XCTAssertEqual(historyStore.updatedMedicines.count, 1)
        XCTAssertEqual(historyStore.updateDetails.first?.previousName, "Doliprane")
        XCTAssertEqual(historyStore.updateDetails.first?.previousAisle, "AD56")
        XCTAssertEqual(medicineStore.savedMedicines.last?.name, "Dafalgan")
        XCTAssertEqual(medicineStore.savedMedicines.last?.aisle, "AD10")
    }
}
