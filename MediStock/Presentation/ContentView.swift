import SwiftUI
import Toasty

struct ContentView: View {
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel

    var body: some View {
        Group {
            if authenticationViewModel.session != nil {
                MainTabView()
            } else if !authenticationViewModel.isConnected {
                OfflineView()
            } else {
                AuthenticationView()
            }
        }
        .overlay {
            if authenticationViewModel.isLoading {
                LoadingOverlay()
            }
        }
        .onAppear {
            authenticationViewModel.listen()
            authenticationViewModel.listenConnectivity()
        }
    }
}

// TODO: rebuild with PreviewHelper once it lands on this branch.
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            .environmentObject(AuthenticationViewModel(authenticationService: FirebaseAuthenticationService(),
//                                                       networkMonitor: NetworkMonitor()))
//            .environmentObject(ToastyManager())
//    }
//}
