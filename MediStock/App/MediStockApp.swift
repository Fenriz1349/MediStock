//
//  MediStockApp.swift
//  MediStock
//
//  Created by Vincent Saluzzo on 28/05/2024.
//

import SwiftUI
import Firebase
import FirebaseAuth
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
        #if DEBUG
        Self.configureForUITestingIfNeeded(settings: settings)
        #endif
        Firestore.firestore().settings = settings
        let container = DIContainer()
        self.container = container
        _authenticationViewModel = StateObject(wrappedValue: container.makeAuthenticationViewModel())
    }

    #if DEBUG
    /// Redirects Auth/Firestore to the local Firebase emulator and clears any locally cached session.
    /// Active only when launched with the `UI-TESTING` argument (see `MediStockUITests`).
    /// Launch `firebase emulators:start` first — both settings go on the same `settings` object, since
    /// `Firestore.firestore().settings` silently drops a second assignment after the first.
    /// A signed-in session persists locally (Keychain) across launches, independent of which backend is configured.
    /// The forced sign-out guarantees a deterministic start on `AuthenticationView` regardless of that.
    /// DEBUG-only: compiled out of Release builds entirely.
    private static func configureForUITestingIfNeeded(settings: FirestoreSettings) {
        guard ProcessInfo.processInfo.arguments.contains("UI-TESTING") else { return }
        Auth.auth().useEmulator(withHost: "127.0.0.1", port: 9099)
        settings.host = "127.0.0.1:8080"
        settings.isSSLEnabled = false
        try? Auth.auth().signOut()
    }
    #endif

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
