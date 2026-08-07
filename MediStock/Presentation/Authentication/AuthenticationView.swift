//
//  AuthenticationView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI
import Toasty

struct AuthenticationView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @EnvironmentObject var toasty: ToastyManager

    var body: some View {
        let unmetPasswordRequirements = PasswordPolicy.unmetRequirements(for: password)

        VStack {
            TextField("auth.email.placeholder", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("auth.password.placeholder", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
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
            .disabled(!unmetPasswordRequirements.isEmpty)
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
            .environmentObject(AuthenticationViewModel(authenticationService: FirebaseAuthenticationService()))
            .environmentObject(ToastyManager())
    }
}
