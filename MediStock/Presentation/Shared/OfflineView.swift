//
//  OfflineView.swift
//  MediStock
//
//  Created by Julien Cotte on 10/08/2026.
//

import SwiftUI

/// Shown instead of `AuthenticationView` when the app starts with no connectivity.
/// There's no session/cache to fall back on at that point, so nothing else in the app would work anyway.
/// `AuthenticationViewModel.isConnected` is live.
/// So this screen already leaves itself automatically the moment connectivity is back.
/// The button below is purely reassurance, not required to make that happen.
/// Deliberately minimal — revisited with a real design once `feat/visual-design`/branding lands.
struct OfflineView: View {
    var body: some View {
        VStack(spacing: 24) {
            ProgressView()

            Text("MediStock")
                .font(.largeTitle)
                .bold()

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
