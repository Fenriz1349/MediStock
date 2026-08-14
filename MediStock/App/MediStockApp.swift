//
//  MediStockApp.swift
//  MediStock
//
//  Created by Vincent Saluzzo on 28/05/2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import Toasty

@main
struct MediStockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    private let container: DIContainer
    @StateObject private var authenticationViewModel: AuthenticationViewModel
    @StateObject private var toasty = ToastyManager()

    init() {
        FirebaseApp.configure()
        // Firestore delivers snapshot listener callbacks on the main queue by default, so decoding a
        // whole medicine list on every update would block it. Must run before any Firestore access —
        // the SDK silently ignores settings applied after the first use.
        let settings = FirestoreSettings()
        settings.dispatchQueue = DispatchQueue(label: "com.medistock.firestore", qos: .utility)
        Firestore.firestore().settings = settings
        let container = DIContainer()
        self.container = container
        _authenticationViewModel = StateObject(wrappedValue: container.makeAuthenticationViewModel())
    }

    var body: some Scene {
        WindowGroup {
            ToastyContainer(manager: toasty) {
                ContentView()
                    .environmentObject(authenticationViewModel)
                    .environment(\.diContainer, container)
                    .environmentObject(toasty)
            }
        }
    }
}
