//
//  LoginView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var session: SessionStore

    var body: some View {
        VStack {
            TextField("auth.email.placeholder", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("auth.password.placeholder", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: {
                session.signIn(email: email, password: password)
            }) {
                Text("auth.login.button")
            }
            Button(action: {
                session.signUp(email: email, password: password)
            }) {
                Text("auth.signUp.button")
            }
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(SessionStore())
    }
}
