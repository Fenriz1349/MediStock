//
//  TestHelper.swift
//  MediStockTests
//
//  Created by Julien Cotte on 24/07/2026.
//

import Foundation
@testable import MediStock

/// Factory helpers for building test fixtures. Pure functions only, no shared mutable state.
/// So tests stay independent and safe to run in any order.
enum TestHelper {
    static func makeAppUser(
        uid: String = "user-1",
        email: String? = "test@example.com"
    ) -> AppUser {
        AppUser(uid: uid, email: email)
    }

    static func makeMedicine(
        id: String? = "medicine-1",
        name: String = "Doliprane",
        stock: Int = 10,
        aisle: String = "Rayon 1"
    ) -> Medicine {
        Medicine(id: id, name: name, stock: stock, aisle: aisle)
    }

    static func makeHistoryEntry(
        id: String? = "history-1",
        medicineId: String = "medicine-1",
        user: String = "test@example.com",
        action: String = "Added Doliprane",
        details: String = "Added new medicine",
        timestamp: Date = Date(timeIntervalSince1970: 0)
    ) -> HistoryEntry {
        HistoryEntry(id: id, medicineId: medicineId, user: user, action: action, details: details, timestamp: timestamp)
    }

    /// Polls `condition` until it's true or `timeout` elapses.
    /// Use instead of a fixed `Task.sleep` to await an async side effect.
    /// E.g. an `AsyncStream` emission reaching a `@Published` property.
    /// Avoids guessing a delay that may be too short under load.
    static func waitUntil(timeout: TimeInterval = 1, _ condition: () -> Bool) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() && Date() < deadline {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }

    /// Builds an `AuthenticationViewModel` wired to fresh mocks by default.
    /// So tests only need to pass what they actually care about configuring/inspecting.
    @MainActor
    static func makeAuthenticationViewModel(
        authenticationService: AuthenticationServicing = AuthenticationServicingDouble(),
        networkMonitor: NetworkMonitoring = NetworkMonitoringDouble()
    ) -> AuthenticationViewModel {
        AuthenticationViewModel(authenticationService: authenticationService, networkMonitor: networkMonitor)
    }

    /// Builds an `AddMedicineViewModel` wired to fresh mocks by default.
    @MainActor
    static func makeAddMedicineViewModel(
        medicineStore: MedicineStoring = MedicineStoringDouble(),
        historyStore: HistoryStoring = HistoryStoringDouble(),
        networkMonitor: NetworkMonitoring = NetworkMonitoringDouble()
    ) -> AddMedicineViewModel {
        AddMedicineViewModel(medicineStore: medicineStore, historyStore: historyStore, networkMonitor: networkMonitor)
    }

    /// Builds a `MedicineDetailViewModel` wired to fresh mocks by default.
    @MainActor
    static func makeMedicineDetailViewModel(
        medicine: Medicine = TestHelper.makeMedicine(),
        medicineStore: MedicineStoring = MedicineStoringDouble(),
        historyStore: HistoryStoring = HistoryStoringDouble(),
        networkMonitor: NetworkMonitoring = NetworkMonitoringDouble()
    ) -> MedicineDetailViewModel {
        MedicineDetailViewModel(
            medicine: medicine,
            medicineStore: medicineStore,
            historyStore: historyStore,
            networkMonitor: networkMonitor
        )
    }

    /// Builds an `AisleMedicinesViewModel` wired to a fresh mock by default.
    @MainActor
    static func makeAisleMedicinesViewModel(
        aisle: String = "Rayon 1",
        medicineStore: MedicineStoring = MedicineStoringDouble()
    ) -> AisleMedicinesViewModel {
        AisleMedicinesViewModel(aisle: aisle, medicineStore: medicineStore)
    }

    /// Builds an `AisleListViewModel` wired to a fresh mock by default.
    @MainActor
    static func makeAisleListViewModel(
        medicineStore: MedicineStoring = MedicineStoringDouble()
    ) -> AisleListViewModel {
        AisleListViewModel(medicineStore: medicineStore)
    }

    /// Builds an `AllMedicinesViewModel` wired to a fresh mock by default.
    @MainActor
    static func makeAllMedicinesViewModel(
        medicineStore: MedicineStoring = MedicineStoringDouble()
    ) -> AllMedicinesViewModel {
        AllMedicinesViewModel(medicineStore: medicineStore)
    }
}
