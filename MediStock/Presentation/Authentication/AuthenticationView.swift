//
//  AuthenticationView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI

struct AuthenticationView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthenticationViewModel

    var body: some View {
        VStack {
            TextField("auth.email.placeholder", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("auth.password.placeholder", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
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
        }
        .padding()
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthenticationViewModel(authenticationService: FirebaseAuthenticationService()))
    }
}
