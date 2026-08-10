//
//  AisleMedicinesViewModelTest.swift
//  MediStockTests
//
//  Created by Julien Cotte on 10/08/2026.
//

import XCTest
@testable import MediStock

final class AisleMedicinesViewModelTest: XCTestCase {
    @MainActor
    func testAisle_afterInit_exposesConstructorValue() {
        let viewModel = TestHelper.makeAisleMedicinesViewModel(aisle: "AD56")

        XCTAssertEqual(viewModel.aisle, "AD56")
    }

    @MainActor
    func testListen_medicinesEmitted_populatesMedicines() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeAisleMedicinesViewModel(medicineStore: medicineStore)
        let medicine = TestHelper.makeMedicine()

        viewModel.listen()
        medicineStore.emit([medicine])
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }

        XCTAssertEqual(viewModel.medicines, [medicine])
    }

    @MainActor
    func testListen_subsequentEmission_updatesMedicines() async {
        let medicineStore = MockMedicineStoring()
        let viewModel = TestHelper.makeAisleMedicinesViewModel(medicineStore: medicineStore)
        let first = TestHelper.makeMedicine(id: "1")
        let second = TestHelper.makeMedicine(id: "2")

        viewModel.listen()
        medicineStore.emit([first])
        await TestHelper.waitUntil { !viewModel.medicines.isEmpty }
        medicineStore.emit([first, second])
        await TestHelper.waitUntil { viewModel.medicines.count == 2 }

        XCTAssertEqual(viewModel.medicines, [first, second])
    }
}
