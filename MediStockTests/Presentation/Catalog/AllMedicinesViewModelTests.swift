//
//  AllMedicinesViewModelTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 10/08/2026.
//

import XCTest
@testable import MediStock

final class AllMedicinesViewModelTests: XCTestCase {
    @MainActor
    func testListenPopulatesMedicines() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeAllMedicinesViewModel(medicineStore: medicineStore)
        let medicine = TestHelper.makeMedicine()

        viewModel.listen()
        medicineStore.emit([medicine])
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }

        XCTAssertEqual(viewModel.medicines, [medicine])
    }

    @MainActor
    func testChangingSortOptionRequeriesWithTheNewOption() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeAllMedicinesViewModel(medicineStore: medicineStore)
        viewModel.listen()
        await TestHelper.waitUntil { medicineStore.requestedSortOptions == [.none] }

        viewModel.sortOption = .stock

        await TestHelper.waitUntil { medicineStore.requestedSortOptions == [.none, .stock] }
        XCTAssertEqual(medicineStore.requestedSortOptions, [.none, .stock])
    }

    @MainActor
    func testMedicinesMatchingReturnsEverythingWhenFilterIsEmpty() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeAllMedicinesViewModel(medicineStore: medicineStore)
        let medicines = [TestHelper.makeMedicine(id: "1", name: "Doliprane"), TestHelper.makeMedicine(id: "2", name: "Advil")]

        viewModel.listen()
        medicineStore.emit(medicines)
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }

        XCTAssertEqual(viewModel.medicines(matching: ""), medicines)
    }

    @MainActor
    func testMedicinesMatchingFindsASubstringAnywhereInTheName() async {
        // Kept local specifically so this can match anywhere in the name, not just a prefix —
        // a Firestore-side query could only do "starts with".
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeAllMedicinesViewModel(medicineStore: medicineStore)
        let medicines = [
            TestHelper.makeMedicine(id: "1", name: "Doliprane"),
            TestHelper.makeMedicine(id: "2", name: "Advil")
        ]

        viewModel.listen()
        medicineStore.emit(medicines)
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }

        let result = viewModel.medicines(matching: "liprane")

        XCTAssertEqual(result.map(\.id), ["1"])
    }
}
