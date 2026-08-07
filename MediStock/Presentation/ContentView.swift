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
            } else {
                AuthenticationView()
            }
        }
        .onAppear {
            authenticationViewModel.listen()
        }
        .onChange(of: authenticationViewModel.session) { _, session in
            // Only start listening once a session actually exists: Firestore's security rules
            // require `request.auth != null`, and attaching this listener before the session is
            // confirmed gets a permanent "permission-denied" that doesn't self-recover once the
            // session does arrive.
            if session != nil {
                catalogViewModel.listen()
            }
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
            .environmentObject(AuthenticationViewModel(authenticationService: FirebaseAuthenticationService()))
            .environmentObject(CatalogViewModel(medicineStore: FirestoreMedicineStore(),
                                                historyStore: FirestoreHistoryStore()))
            .environmentObject(ToastyManager())
    }
}
