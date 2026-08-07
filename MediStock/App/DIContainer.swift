//
//  DIContainer.swift
//  MediStock
//
//  Created by Julien Cotte on 07/08/2026.
//

import Foundation
import SwiftUI

/// Composition root: owns the concrete Data-layer implementations and builds ViewModels from them.
/// Views ask this container for a ViewModel instead of constructing Firestore/Firebase types
/// themselves, so those concrete types stay out of the View and ViewModel layers.
struct DIContainer {
    private let medicineStore: MedicineStoring
    private let historyStore: HistoryStoring
    private let authenticationService: AuthenticationServicing

    init(
        medicineStore: MedicineStoring = FirestoreMedicineStore(),
        historyStore: HistoryStoring = FirestoreHistoryStore(authenticationService: FirebaseAuthenticationService()),
        authenticationService: AuthenticationServicing = FirebaseAuthenticationService()
    ) {
        self.medicineStore = medicineStore
        self.historyStore = historyStore
        self.authenticationService = authenticationService
    }

    @MainActor
    func makeAuthenticationViewModel() -> AuthenticationViewModel {
        AuthenticationViewModel(authenticationService: authenticationService)
    }

    @MainActor
    func makeCatalogViewModel() -> CatalogViewModel {
        CatalogViewModel(medicineStore: medicineStore, historyStore: historyStore)
    }

    @MainActor
    func makeMedicineDetailViewModel(medicine: Medicine) -> MedicineDetailViewModel {
        MedicineDetailViewModel(
            medicine: medicine,
            medicineStore: medicineStore,
            historyStore: historyStore
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
