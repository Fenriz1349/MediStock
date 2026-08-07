//
//  MediStockApp.swift
//  MediStock
//
//  Created by Vincent Saluzzo on 28/05/2024.
//

import SwiftUI
import Firebase
import Toasty

@main
struct MediStockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    private let container: DIContainer
    @StateObject private var authenticationViewModel: AuthenticationViewModel
    @StateObject private var catalogViewModel: CatalogViewModel
    @StateObject private var toasty = ToastyManager()

    init() {
        FirebaseApp.configure()
        let container = DIContainer()
        self.container = container
        _authenticationViewModel = StateObject(wrappedValue: container.makeAuthenticationViewModel())
        _catalogViewModel = StateObject(wrappedValue: container.makeCatalogViewModel())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authenticationViewModel)
                .environmentObject(catalogViewModel)
                .environment(\.diContainer, container)
        }
    }
}
