//
//  MediStockApp.swift
//  MediStock
//
//  Created by Vincent Saluzzo on 28/05/2024.
//

import SwiftUI

@main
struct MediStockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authenticationViewModel = AuthenticationViewModel(authenticationService: FirebaseAuthenticationService())
    @StateObject private var catalogViewModel = CatalogViewModel(medicineStore: FirestoreMedicineStore(), historyStore: FirestoreHistoryStore())

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authenticationViewModel)
                .environmentObject(catalogViewModel)
        }
    }
}
