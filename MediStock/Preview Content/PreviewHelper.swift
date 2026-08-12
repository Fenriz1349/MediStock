//
//  PreviewHelper.swift
//  MediStock
//
//  Created by Julien Cotte on 11/08/2026.
//

import Foundation

/// Canned sample data and pre-filled ViewModels for SwiftUI Previews.
/// The app is small enough that a separate `PreviewData` file isn't warranted.
/// So the sample data and the fake stores that serve it both live here, in one place.
/// Every screen's preview should read `PreviewHelper.container.make...ViewModel()` instead of
/// `DIContainer()`, so previews show a believable list instead of an empty one hitting no backend.
enum PreviewHelper {
    static let sampleUser = AppUser(uid: "preview-user", email: "test@medistock.fr")

    static let sampleMedicines: [Medicine] = [
        Medicine(id: "1", name: "Doliprane", stock: 42, aisle: "AD2"),
        Medicine(id: "2", name: "Dafalgan", stock: 12, aisle: "AD2"),
        Medicine(id: "3", name: "Ibuprofène", stock: 5, aisle: "AD10"),
        Medicine(id: "4", name: "Aspirine", stock: 0, aisle: "AD10"),
        Medicine(id: "5", name: "Amoxicilline", stock: 60, aisle: "AD56")
    ]

    /// The medicine used by every preview that needs just one, e.g. `MedicineDetailView`.
    static let sampleMedicine = sampleMedicines[0]

    /// History entries for `sampleMedicine`, most recent last.
    static let sampleHistory: [HistoryEntry] = [
        HistoryEntry(
            id: "h1",
            medicineId: sampleMedicine.id ?? "",
            user: sampleUser.email ?? "",
            action: "Added Doliprane",
            details: "Added new medicine with initial stock of 30",
            timestamp: Date().addingTimeInterval(-86_400 * 3)
        ),
        HistoryEntry(
            id: "h2",
            medicineId: sampleMedicine.id ?? "",
            user: sampleUser.email ?? "",
            action: "Increased stock",
            details: "Increased stock from 30 to 42",
            timestamp: Date().addingTimeInterval(-3_600)
        )
    ]

    /// A `DIContainer` backed entirely by the fake stores below, instead of Firestore/Firebase.
    /// Drop-in replacement for `DIContainer()` in any `#Preview`.
    /// Every `make...ViewModel()` factory works unchanged, since `DIContainer` only depends on the
    /// Domain protocols, never on a concrete Firestore/Firebase type.
    static var container: DIContainer {
        DIContainer(
            medicineStore: PreviewMedicineStore(),
            historyStore: PreviewHistoryStore(),
            authenticationService: PreviewAuthenticationService(),
            networkMonitor: PreviewNetworkMonitor()
        )
    }
}

/// Fake `MedicineStoring` for Previews, serving `PreviewHelper.sampleMedicines` instead of Firestore.
/// Each stream yields once and finishes.
/// Previews need a believable static snapshot, not a live subscription.
private struct PreviewMedicineStore: MedicineStoring {
    func observeMedicines() -> AsyncStream<[Medicine]> {
        AsyncStream { continuation in
            continuation.yield(PreviewHelper.sampleMedicines)
            continuation.finish()
        }
    }

    func observeMedicines(sortedBy sortOption: SortOption, ascending: Bool) -> AsyncStream<[Medicine]> {
        let sorted: [Medicine]
        switch sortOption {
        case .none:
            sorted = PreviewHelper.sampleMedicines
        case .name:
            sorted = PreviewHelper.sampleMedicines.sorted { ascending ? $0.name < $1.name : $0.name > $1.name }
        case .stock:
            sorted = PreviewHelper.sampleMedicines.sorted { ascending ? $0.stock < $1.stock : $0.stock > $1.stock }
        }
        return AsyncStream { continuation in
            continuation.yield(sorted)
            continuation.finish()
        }
    }

    func observeMedicines(inAisle aisle: String) -> AsyncStream<[Medicine]> {
        let filtered = PreviewHelper.sampleMedicines.filter { $0.aisle == aisle }
        return AsyncStream { continuation in
            continuation.yield(filtered)
            continuation.finish()
        }
    }

    func observeMedicines(nameStartingWith prefix: String) -> AsyncStream<[Medicine]> {
        let filtered = PreviewHelper.sampleMedicines.filter { $0.name.hasPrefix(prefix) }
        return AsyncStream { continuation in
            continuation.yield(filtered)
            continuation.finish()
        }
    }

    func save(_ medicine: Medicine) async throws -> Medicine {
        var saved = medicine
        if saved.id == nil {
            saved.id = UUID().uuidString
        }
        return saved
    }

    func delete(_ medicine: Medicine) async throws {}
}

/// Fake `HistoryStoring` for Previews, serving `PreviewHelper.sampleHistory` instead of Firestore.
/// Every medicine ID gets the same sample history.
/// Previews only ever show one medicine at a time, so there's nothing to tell apart.
private struct PreviewHistoryStore: HistoryStoring {
    func observeHistory(forMedicineId medicineId: String) -> AsyncStream<[HistoryEntry]> {
        AsyncStream { continuation in
            continuation.yield(PreviewHelper.sampleHistory)
            continuation.finish()
        }
    }

    func recordAddition(of medicine: Medicine) async throws {}
    func recordUpdate(of medicine: Medicine) async throws {}
    func recordStockChange(of medicine: Medicine, from previousStock: Int) async throws {}
    func recordDeletion(of medicine: Medicine) async throws {}
}

/// Fake `AuthenticationServicing` for Previews, always signed in as `PreviewHelper.sampleUser`.
private struct PreviewAuthenticationService: AuthenticationServicing {
    var currentUser: AppUser? { PreviewHelper.sampleUser }

    func observeSession() -> AsyncStream<AppUser?> {
        AsyncStream { continuation in
            continuation.yield(PreviewHelper.sampleUser)
            continuation.finish()
        }
    }

    func signUp(email: String, password: String) async throws -> AppUser { PreviewHelper.sampleUser }
    func signIn(email: String, password: String) async throws -> AppUser { PreviewHelper.sampleUser }
    func signOut() throws {}
    func deleteAccount() async throws {}
}

/// Fake `NetworkMonitoring` for Previews, always reachable.
private struct PreviewNetworkMonitor: NetworkMonitoring {
    var isConnected: Bool { true }

    func observeConnectivity() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            continuation.yield(true)
            continuation.finish()
        }
    }

    func verifyReachable() async throws {}
}
