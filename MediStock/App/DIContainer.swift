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
/// So those concrete types stay out of the View and ViewModel layers.
struct DIContainer {
    private let medicineStore: MedicineStoring
    private let historyStore: HistoryStoring
    private let authenticationService: AuthenticationServicing
    private let networkMonitor: NetworkMonitoring

    init(
        medicineStore: MedicineStoring = FirestoreMedicineStore(),
        historyStore: HistoryStoring = FirestoreHistoryStore(authenticationService: FirebaseAuthenticationService()),
        authenticationService: AuthenticationServicing = FirebaseAuthenticationService(),
        networkMonitor: NetworkMonitoring = NetworkMonitor()
    ) {
        self.medicineStore = medicineStore
        self.historyStore = historyStore
        self.authenticationService = authenticationService
        self.networkMonitor = networkMonitor
    }

    @MainActor
    func makeAuthenticationViewModel() -> AuthenticationViewModel {
        AuthenticationViewModel(authenticationService: authenticationService, networkMonitor: networkMonitor)
    }

    @MainActor
    func makeCatalogViewModel() -> CatalogViewModel {
        CatalogViewModel(medicineStore: medicineStore, historyStore: historyStore, networkMonitor: networkMonitor)
    }

    @MainActor
    func makeMedicineDetailViewModel(medicine: Medicine) -> MedicineDetailViewModel {
        MedicineDetailViewModel(
            medicine: medicine,
            medicineStore: medicineStore,
            historyStore: historyStore,
            networkMonitor: networkMonitor
        )
    }

    /// - Parameter aisle: The exact aisle code the screen should show medicines for.
    @MainActor
    func makeAisleMedicinesViewModel(aisle: String) -> AisleMedicinesViewModel {
        AisleMedicinesViewModel(aisle: aisle, medicineStore: medicineStore)
    }

    @MainActor
    func makeAisleListViewModel() -> AisleListViewModel {
        AisleListViewModel(medicineStore: medicineStore)
    }

    @MainActor
    func makeAllMedicinesViewModel() -> AllMedicinesViewModel {
        AllMedicinesViewModel(medicineStore: medicineStore)
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
