//
//  AuthenticationView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI
import Toasty
import CustomTextFields

struct AuthenticationView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @EnvironmentObject var toasty: ToastyManager
    @State private var isEmailFocused = false

    var body: some View {
        VStack {
            AppLogo()
                .padding(.bottom, 24)

            CustomTextField.triggered(
                placeholder: String(localized: "auth.email.placeholder"),
                text: $viewModel.email,
                type: .email,
                validator: EmailPolicy.isValid,
                errorMessage: String(localized: "auth.email.invalidFormat"),
                validationState: $viewModel.emailState,
                isFocusedBinding: $isEmailFocused
            )
            .padding()

            Button(action: {
                Task { await viewModel.sendPasswordReset(email: viewModel.email) }
            }, label: {
                Text("auth.forgotPasswordButton")
                    .font(.footnote)
            })
            .disabled(!EmailPolicy.isValid(viewModel.email))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal)

            CustomTextField.triggered(
                placeholder: String(localized: "auth.password.placeholder"),
                text: $viewModel.password,
                type: .password,
                validator: PasswordPolicy.isValid,
                errorMessage: String(localized: "auth.password.invalidFormat"),
                validationState: $viewModel.passwordState
            )
            .padding()

            VStack(alignment: .leading, spacing: 4) {
                ForEach(PasswordRequirement.allCases, id: \.self) { requirement in
                    let isMet = !viewModel.unmetPasswordRequirements.contains(requirement)
                    HStack {
                        Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                            .accessibilityHidden(true)
                        Text(requirement.localizedDescription)
                    }
                    .foregroundColor(isMet ? .green : .secondary)
                }
            }
            .padding(.horizontal)

            Button(action: {
                Task { await viewModel.signIn() }
            }, label: {
                Text("auth.login.button")
            })
            .buttonStyle(AppButtonStyle())
            .disabled(!viewModel.isFormValid)
            .padding(.horizontal, 24)

            Button(action: {
                Task { await viewModel.signUp() }
            }, label: {
                Text("auth.signUp.button")
            })
            .buttonStyle(AppButtonStyle())
            .disabled(!viewModel.isFormValid)
            .padding(.horizontal, 24)
        }
        .padding()
        .toolbar {
            KeyboardToolBar(isValidateEnabled: viewModel.isFormValid) {
                Task { await viewModel.signIn() }
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
        .onAppear {
            // Only for VoiceOver: skips the swipe to reach the first field.
            // Sighted users get the plain screen instead of an unprompted keyboard.
            if UIAccessibility.isVoiceOverRunning {
                isEmailFocused = true
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(PreviewHelper.container.makeAuthenticationViewModel())
            .environmentObject(ToastyManager())
    }
}
