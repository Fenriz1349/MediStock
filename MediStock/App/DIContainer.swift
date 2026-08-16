//
//  DIContainer.swift
//  MediStock
//
//  Created by Julien Cotte on 07/08/2026.
//

import Foundation
import SwiftUI

/// Composition root: owns the concrete Data-layer implementations and builds ViewModels from them.
/// Views ask this container for a ViewModel instead of constructing Firestore/Firebase types themselves.
struct DIContainer {
    private let medicineStore: MedicineStoring
    private let historyStore: HistoryStoring
    private let aisleStore: AisleStoring
    private let authenticationService: AuthenticationServicing
    private let networkMonitor: NetworkMonitoring

    init(
        medicineStore: MedicineStoring = FirestoreMedicineStore(),
        historyStore: HistoryStoring = FirestoreHistoryStore(authenticationService: FirebaseAuthenticationService()),
        aisleStore: AisleStoring = FirestoreAisleStore(),
        authenticationService: AuthenticationServicing = FirebaseAuthenticationService(),
        networkMonitor: NetworkMonitoring = NetworkMonitor()
    ) {
        self.medicineStore = medicineStore
        self.historyStore = historyStore
        self.aisleStore = aisleStore
        self.authenticationService = authenticationService
        self.networkMonitor = networkMonitor
    }

    @MainActor
    func makeAuthenticationViewModel() -> AuthenticationViewModel {
        AuthenticationViewModel(authenticationService: authenticationService, networkMonitor: networkMonitor)
    }

    /// - Parameter existingMedicine: `nil` to create a new medicine, or the medicine being edited.
    @MainActor
    func makeMedicineFormViewModel(existingMedicine: Medicine? = nil) -> MedicineFormViewModel {
        MedicineFormViewModel(
            existingMedicine: existingMedicine,
            medicineStore: medicineStore,
            historyStore: historyStore,
            aisleStore: aisleStore,
            networkMonitor: networkMonitor
        )
    }

    @MainActor
    func makeMedicineDetailViewModel(medicine: Medicine) -> MedicineDetailViewModel {
        MedicineDetailViewModel(
            medicine: medicine,
            medicineStore: medicineStore,
            historyStore: historyStore,
            aisleStore: aisleStore,
            networkMonitor: networkMonitor
        )
    }

    /// - Parameter aisle: The exact aisle code the screen should show medicines for.
    @MainActor
    func makeAisleMedicinesViewModel(aisle: String) -> AisleMedicinesViewModel {
        AisleMedicinesViewModel(
            aisle: aisle,
            medicineStore: medicineStore,
            historyStore: historyStore,
            aisleStore: aisleStore,
            networkMonitor: networkMonitor
        )
    }

    @MainActor
    func makeAisleListViewModel() -> AisleListViewModel {
        AisleListViewModel(aisleStore: aisleStore)
    }

    @MainActor
    func makeAllMedicinesViewModel() -> AllMedicinesViewModel {
        AllMedicinesViewModel(
            medicineStore: medicineStore,
            historyStore: historyStore,
            aisleStore: aisleStore,
            networkMonitor: networkMonitor
        )
    }
}

private struct DIContainerKey: EnvironmentKey {
    static let defaultValue = DIContainer()
}

extension EnvironmentValues {
    var diContainer: DIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}
