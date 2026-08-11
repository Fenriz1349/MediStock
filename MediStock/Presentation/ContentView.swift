import SwiftUI
import Toasty

struct ContentView: View {
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    @EnvironmentObject var catalogViewModel: CatalogViewModel
    @EnvironmentObject var toasty: ToastyManager

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
            if authenticationViewModel.isLoading || catalogViewModel.isLoading {
                LoadingOverlay()
            }
        }
        .onAppear {
            authenticationViewModel.listen()
            authenticationViewModel.listenConnectivity()
        }
        .onChange(of: catalogViewModel.error) { _, error in
            if let error {
                toasty.showError(error.localizedMessage)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PreviewHelper.container.makeAuthenticationViewModel())
            .environmentObject(PreviewHelper.container.makeCatalogViewModel())
            .environmentObject(ToastyManager())
            .environment(\.diContainer, PreviewHelper.container)
    }
}
