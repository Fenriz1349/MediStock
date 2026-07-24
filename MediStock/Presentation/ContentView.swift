import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel

    var body: some View {
        Group {
            if authenticationViewModel.session != nil {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .onAppear {
            authenticationViewModel.listen()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AuthenticationViewModel(authenticationService: FirebaseAuthenticationService()))
    }
}
