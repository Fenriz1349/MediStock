//
//  UserView.swift
//  MediStock
//
//  Created by Julien Cotte on 07/08/2026.
//

import SwiftUI
import Toasty

/// Account screen: shows the connected user's email.
/// Lets them reset their password, sign out, or permanently delete their account.
struct UserView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @EnvironmentObject var toasty: ToastyManager
    @State private var isPresentingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true)

                    Text(viewModel.session?.email ?? "TEST")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 40)

                VStack(spacing: 12) {
                    Button(action: {
                        Task { await viewModel.sendPasswordReset(email: viewModel.session?.email ?? "") }
                    }, label: {
                        Text("user.resetPasswordButton")
                    })
                    .buttonStyle(AppButtonStyle())

                    Button(action: {
                        viewModel.signOut()
                    }, label: {
                        Text("user.logoutButton")
                    })
                    .buttonStyle(AppButtonStyle())

                    Button(role: .destructive, action: {
                        isPresentingDeleteConfirmation = true
                    }, label: {
                        Text("user.deleteAccountButton")
                    })
                    .buttonStyle(AppButtonStyle(color: .red))
                }

                Spacer()
            }
            .padding()
            .navigationBarTitle("tab.user.title", displayMode: .inline)
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
        .onChange(of: viewModel.didSendPasswordReset) { _, _ in
            toasty.showSuccess(String(localized: "user.resetPassword.successMessage"))
        }
    }
}

#Preview {
    UserView()
        .environmentObject(PreviewHelper.container.makeAuthenticationViewModel())
        .environmentObject(ToastyManager())
}
