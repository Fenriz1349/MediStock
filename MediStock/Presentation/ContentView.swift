import SwiftUI
import Toasty

struct ContentView: View {
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    /// Keeps `LoadingView` on screen at least this long, even if the session resolves sooner.
    /// Avoids a flash of `LoadingView` for returning users whose session confirms almost instantly.
    @State private var minimumLoadingDelayElapsed = false

    private var isShowingLaunchLoading: Bool {
        !authenticationViewModel.hasResolvedSession || !minimumLoadingDelayElapsed
    }

    var body: some View {
        Group {
            if isShowingLaunchLoading {
                LoadingView()
            } else if authenticationViewModel.session != nil {
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
            Task {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                minimumLoadingDelayElapsed = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PreviewHelper.container.makeAuthenticationViewModel())
            .environmentObject(ToastyManager())
            .environment(\.diContainer, PreviewHelper.container)
    }
}
