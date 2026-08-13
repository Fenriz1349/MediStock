//
//  OfflineView.swift
//  MediStock
//
//  Created by Julien Cotte on 10/08/2026.
//

import SwiftUI

/// Shown instead of `AuthenticationView` when the app starts with no connectivity.
/// Leaves automatically once `AuthenticationViewModel.isConnected` goes live again.
struct OfflineView: View {
    var body: some View {
        VStack(spacing: 24) {
            AppLogo()

            ProgressView()

            Text("offline.message")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("offline.retryButton", action: {})
        }
    }
}

#Preview {
    OfflineView()
}
