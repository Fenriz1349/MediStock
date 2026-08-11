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
    @State private var email = ""
    @State private var password = ""
    @State private var emailState: ValidationState = .neutral
    @State private var passwordState: ValidationState = .neutral
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @EnvironmentObject var toasty: ToastyManager

    var body: some View {
        let unmetPasswordRequirements = PasswordPolicy.unmetRequirements(for: password)

        VStack {
            CustomTextField.triggered(
                placeholder: String(localized: "auth.email.placeholder"),
                text: $email,
                type: .email,
                validator: EmailPolicy.isValid,
                errorMessage: String(localized: "auth.email.invalidFormat"),
                validationState: $emailState
            )
            .padding()

            CustomTextField.triggered(
                placeholder: String(localized: "auth.password.placeholder"),
                text: $password,
                type: .password,
                validator: PasswordPolicy.isValid,
                errorMessage: String(localized: "auth.password.invalidFormat"),
                validationState: $passwordState
            )
            .padding()

            VStack(alignment: .leading, spacing: 4) {
                ForEach(PasswordRequirement.allCases, id: \.self) { requirement in
                    HStack {
                        Image(systemName: unmetPasswordRequirements.contains(requirement) ? "circle" : "checkmark.circle.fill")
                        Text(requirement.localizedDescription)
                    }
                    .foregroundColor(unmetPasswordRequirements.contains(requirement) ? .secondary : .green)
                }
            }
            .padding(.horizontal)

            Button(action: {
                Task { await viewModel.signIn(email: email, password: password) }
            }, label: {
                Text("auth.login.button")
            })
            Button(action: {
                Task { await viewModel.signUp(email: email, password: password) }
            }, label: {
                Text("auth.signUp.button")
            })
            .disabled(!unmetPasswordRequirements.isEmpty || emailState != .valid)
        }
        .padding()
        .onChange(of: viewModel.error) { _, error in
            if let error {
                toasty.showError(error.localizedMessage)
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthenticationViewModel(authenticationService: FirebaseAuthenticationService(),
                                                        networkMonitor: NetworkMonitor()))
            .environmentObject(ToastyManager())
    }
}
