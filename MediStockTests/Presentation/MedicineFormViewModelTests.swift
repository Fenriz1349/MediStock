//
//  MedicineFormViewModelTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 11/08/2026.
//

import XCTest
@testable import MediStock

final class MedicineFormViewModelTests: XCTestCase {
    @MainActor
    func testSave_success_savesAndRecordsHistory() async {
        let medicineStore = MedicineStoringDouble()
        let historyStore = HistoryStoringDouble()
        let viewModel = TestHelper.makeMedicineFormViewModel(medicineStore: medicineStore, historyStore: historyStore)
        viewModel.name = "Doliprane"
        viewModel.stockText = "10"

        await viewModel.save(cleanedAisle: "AD56")

        XCTAssertEqual(medicineStore.savedMedicines, [TestHelper.makeMedicine(id: nil,
                                                                              name: "Doliprane",
                                                                              stock: 10,
                                                                              aisle: "AD56")])
        XCTAssertEqual(historyStore.addedMedicines.count, 1)
        XCTAssertNil(viewModel.error)
    }

    @MainActor
    func testSave_name_normalizesCapitalization() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeMedicineFormViewModel(medicineStore: medicineStore)
        viewModel.name = "dOLIPRANE"
        viewModel.stockText = "10"

        await viewModel.save(cleanedAisle: "AD56")

        XCTAssertEqual(medicineStore.savedMedicines.first?.name, "Doliprane")
    }

    @MainActor
    func testSave_invalidStockText_defaultsToZero() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeMedicineFormViewModel(medicineStore: medicineStore)
        viewModel.name = "Doliprane"
        viewModel.stockText = "not-a-number"

        await viewModel.save(cleanedAisle: "AD56")

        XCTAssertEqual(medicineStore.savedMedicines.first?.stock, 0)
    }

    @MainActor
    func testSave_saveFailure_setsTypedErrorAndSkipsHistory() async {
        let medicineStore = MedicineStoringDouble()
        let historyStore = HistoryStoringDouble()
        medicineStore.saveError = MedicineError.network(.serverUnreachable)
        let viewModel = TestHelper.makeMedicineFormViewModel(medicineStore: medicineStore, historyStore: historyStore)

        await viewModel.save(cleanedAisle: "AD56")

        XCTAssertEqual(viewModel.error, .network(.serverUnreachable))
        XCTAssertTrue(historyStore.addedMedicines.isEmpty)
    }

    @MainActor
    func testSave_historyFailure_setsTypedError() async {
        let historyStore = HistoryStoringDouble()
        historyStore.recordError = MedicineError.unknown
        let viewModel = TestHelper.makeMedicineFormViewModel(historyStore: historyStore)

        await viewModel.save(cleanedAisle: "AD56")

        XCTAssertEqual(viewModel.error, .unknown)
    }

    @MainActor
    func testSave_networkUnreachable_skipsStore() async {
        let medicineStore = MedicineStoringDouble()
        let networkMonitor = NetworkMonitoringDouble()
        networkMonitor.verifyReachableError = .notConnected
        let viewModel = TestHelper.makeMedicineFormViewModel(
            medicineStore: medicineStore,
            networkMonitor: networkMonitor
        )

        await viewModel.save(cleanedAisle: "AD56")

        XCTAssertEqual(viewModel.error, .network(.notConnected))
        XCTAssertTrue(medicineStore.savedMedicines.isEmpty)
    }

    @MainActor
    func testSave_inFlight_togglesIsLoading() async {
        let networkMonitor = NetworkMonitoringDouble()
        networkMonitor.verifyReachableDelayNanoseconds = 50_000_000
        let viewModel = TestHelper.makeMedicineFormViewModel(networkMonitor: networkMonitor)
        XCTAssertFalse(viewModel.isLoading)

        let task = Task { await viewModel.save(cleanedAisle: "AD56") }
        await TestHelper.waitUntil { viewModel.isLoading }
        XCTAssertTrue(viewModel.isLoading)

        await task.value

        XCTAssertFalse(viewModel.isLoading)
    }

    @MainActor
    func testIsFormValid_allFieldsValid_returnsTrue() {
        let viewModel = TestHelper.makeMedicineFormViewModel()
        viewModel.name = "Doliprane"
        viewModel.aisle = "AD56"
        viewModel.stockText = "10"

        XCTAssertTrue(viewModel.isFormValid)
    }

    @MainActor
    func testIsFormValid_oneFieldInvalid_returnsFalse() {
        let viewModel = TestHelper.makeMedicineFormViewModel()
        viewModel.name = "Doliprane"
        viewModel.aisle = ""
        viewModel.stockText = "10"

        XCTAssertFalse(viewModel.isFormValid)
    }

    @MainActor
    func testIsFormValid_defaultState_returnsFalse() {
        let viewModel = TestHelper.makeMedicineFormViewModel()

        XCTAssertFalse(viewModel.isFormValid)
    }

    @MainActor
    func testInit_existingMedicine_prefillsNameAisleAndStock() {
        let medicine = TestHelper.makeMedicine(name: "Doliprane", stock: 42, aisle: "AD56")

        let viewModel = TestHelper.makeMedicineFormViewModel(existingMedicine: medicine)

        XCTAssertEqual(viewModel.name, "Doliprane")
        XCTAssertEqual(viewModel.aisle, "AD56")
        XCTAssertEqual(viewModel.stockText, "42")
    }

    @MainActor
    func testInit_noExistingMedicine_leavesFieldsBlank() {
        let viewModel = TestHelper.makeMedicineFormViewModel()

        XCTAssertEqual(viewModel.name, "")
        XCTAssertEqual(viewModel.aisle, "")
        XCTAssertEqual(viewModel.stockText, "")
    }

    @MainActor
    func testIsFormValid_editingWithBlankStock_ignoresStock() {
        let viewModel = TestHelper.makeMedicineFormViewModel(existingMedicine: TestHelper.makeMedicine())
        viewModel.name = "Doliprane"
        viewModel.aisle = "AD56"
        viewModel.stockText = ""

        XCTAssertTrue(viewModel.isFormValid)
    }

    @MainActor
    func testSave_existingMedicine_updatesInsteadOfCreating() async {
        let medicineStore = MedicineStoringDouble()
        let historyStore = HistoryStoringDouble()
        let medicine = TestHelper.makeMedicine(id: "medicine-1", name: "Doliprane", stock: 42, aisle: "AD56")
        let viewModel = TestHelper.makeMedicineFormViewModel(existingMedicine: medicine,
                                                              medicineStore: medicineStore,
                                                              historyStore: historyStore)
        viewModel.name = "Dafalgan"

        await viewModel.save(cleanedAisle: "AD10")

        XCTAssertEqual(medicineStore.savedMedicines.first?.id, "medicine-1")
        XCTAssertEqual(medicineStore.savedMedicines.first?.name, "Dafalgan")
        XCTAssertEqual(medicineStore.savedMedicines.first?.aisle, "AD10")
        XCTAssertEqual(medicineStore.savedMedicines.first?.stock, 42)
        XCTAssertEqual(historyStore.updatedMedicines.count, 1)
        XCTAssertTrue(historyStore.addedMedicines.isEmpty)
        XCTAssertEqual(historyStore.updateDetails.first?.previousName, "Doliprane")
        XCTAssertEqual(historyStore.updateDetails.first?.previousAisle, "AD56")
    }

    @MainActor
    func testSave_success_returnsSavedMedicine() async {
        let medicineStore = MedicineStoringDouble()
        let viewModel = TestHelper.makeMedicineFormViewModel(medicineStore: medicineStore)
        viewModel.name = "Doliprane"
        viewModel.stockText = "10"

        let saved = await viewModel.save(cleanedAisle: "AD56")

        XCTAssertEqual(saved?.name, "Doliprane")
    }

    @MainActor
    func testSave_failure_returnsNil() async {
        let medicineStore = MedicineStoringDouble()
        medicineStore.saveError = MedicineError.unknown
        let viewModel = TestHelper.makeMedicineFormViewModel(medicineStore: medicineStore)
        viewModel.name = "Doliprane"
        viewModel.stockText = "10"

        let saved = await viewModel.save(cleanedAisle: "AD56")

        XCTAssertNil(saved)
    }

    @MainActor
    func testSave_newMedicine_recordsAisleAdded() async {
        let aisleStore = AisleStoringDouble()
        let viewModel = TestHelper.makeMedicineFormViewModel(aisleStore: aisleStore)
        viewModel.name = "Doliprane"
        viewModel.stockText = "10"

        await viewModel.save(cleanedAisle: "AD56")

        XCTAssertEqual(aisleStore.addedToAisles, ["AD56"])
        XCTAssertTrue(aisleStore.removedFromAisles.isEmpty)
    }

    @MainActor
    func testSave_existingMedicineAisleChanged_recordsRemovedThenAdded() async {
        let aisleStore = AisleStoringDouble()
        let medicine = TestHelper.makeMedicine(aisle: "AD56")
        let viewModel = TestHelper.makeMedicineFormViewModel(existingMedicine: medicine, aisleStore: aisleStore)
        viewModel.name = "Doliprane"

        await viewModel.save(cleanedAisle: "AD10")

        XCTAssertEqual(aisleStore.removedFromAisles, ["AD56"])
        XCTAssertEqual(aisleStore.addedToAisles, ["AD10"])
    }

    @MainActor
    func testSave_existingMedicineAisleUnchanged_skipsAisleSync() async {
        let aisleStore = AisleStoringDouble()
        let medicine = TestHelper.makeMedicine(aisle: "AD56")
        let viewModel = TestHelper.makeMedicineFormViewModel(existingMedicine: medicine, aisleStore: aisleStore)
        viewModel.name = "Dafalgan"

        await viewModel.save(cleanedAisle: "AD56")

        XCTAssertTrue(aisleStore.addedToAisles.isEmpty)
        XCTAssertTrue(aisleStore.removedFromAisles.isEmpty)
    }

    @MainActor
    func testSanitizeAisle_containsSlash_stripsIt() {
        let viewModel = TestHelper.makeMedicineFormViewModel()
        viewModel.aisle = "A/D56"

        viewModel.sanitizeAisle()

        XCTAssertEqual(viewModel.aisle, "AD56")
    }

    @MainActor
    func testSanitizeAisle_noSlash_leavesUnchanged() {
        let viewModel = TestHelper.makeMedicineFormViewModel()
        viewModel.aisle = "AD56"

        viewModel.sanitizeAisle()

        XCTAssertEqual(viewModel.aisle, "AD56")
    }

    @MainActor
    func testSanitizeStock_containsLetters_stripsThem() {
        let viewModel = TestHelper.makeMedicineFormViewModel()
        viewModel.stockText = "1a2b3"

        viewModel.sanitizeStock()

        XCTAssertEqual(viewModel.stockText, "123")
    }

    @MainActor
    func testSanitizeStock_alreadyDigitsOnly_leavesUnchanged() {
        let viewModel = TestHelper.makeMedicineFormViewModel()
        viewModel.stockText = "123"

        viewModel.sanitizeStock()

        XCTAssertEqual(viewModel.stockText, "123")
    }
}
