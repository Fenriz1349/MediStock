//
//  MedicineDetailIntegrationTests.swift
//  MediStockTests
//
//  Created by Julien Cotte on 14/08/2026.
//

import XCTest
@testable import MediStock

final class MedicineDetailIntegrationTests: XCTestCase {
    @MainActor
    func testScenario_multipleStockChanges_recordsEachWithCorrectPreviousValue() async {
        let medicineStore = MedicineStoringDouble()
        let historyStore = HistoryStoringDouble()
        let medicine = TestHelper.makeMedicine(stock: 10)
        let viewModel = TestHelper.makeMedicineDetailViewModel(medicine: medicine,
                                                               medicineStore: medicineStore,
                                                               historyStore: historyStore)

        await viewModel.increase()
        await viewModel.increase()
        await viewModel.decrease()

        XCTAssertEqual(viewModel.medicine.stock, 11)
        XCTAssertEqual(historyStore.stockChanges.count, 3)
        XCTAssertEqual(historyStore.stockChanges[0].previousStock, 10)
        XCTAssertEqual(historyStore.stockChanges[1].previousStock, 11)
        XCTAssertEqual(historyStore.stockChanges[2].previousStock, 12)
    }
}
