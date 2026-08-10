//
//  UserView.swift
//  MediStock
//
//  Created by Julien Cotte on 07/08/2026.
//

import SwiftUI
import Toasty

/// Account screen: shows the connected user's email, lets them sign out or permanently delete their account.
/// Uses `AuthenticationViewModel` directly, same VM as `AuthenticationView`.
/// Every action here is an authentication concern.
/// No dedicated ViewModel needed.
struct UserView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @EnvironmentObject var toasty: ToastyManager
    @State private var isPresentingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(viewModel.session?.email ?? "")
                    .font(.headline)
                    .padding(.top, 40)

                Spacer()

                Button(action: {
                    viewModel.signOut()
                }, label: {
                    Text("user.logoutButton")
                })

                Button(role: .destructive, action: {
                    isPresentingDeleteConfirmation = true
                }, label: {
                    Text("user.deleteAccountButton")
                })
            }
            .padding()
            .navigationBarTitle("tab.user.title")
            .alert(
                "user.deleteAccount.confirmTitle",
                isPresented: $isPresentingDeleteConfirmation
            ) {
                Button("user.deleteAccount.confirmButton", role: .destructive) {
                    Task { await viewModel.deleteAccount() }
                }
                Button("user.deleteAccount.cancelButton", role: .cancel) {}
            } message: {
                Text("user.deleteAccount.confirmMessage")
            }
        }
        .onChange(of: viewModel.error) { _, error in
            if let error {
                toasty.showError(error.localizedMessage)
            }
        }
    }
}

#Preview {
    UserView()
        .environmentObject(AuthenticationViewModel(authenticationService: FirebaseAuthenticationService(),
                                                    networkMonitor: NetworkMonitor()))
        .environmentObject(ToastyManager())
}
