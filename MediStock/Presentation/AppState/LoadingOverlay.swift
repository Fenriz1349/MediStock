//
//  LoadingOverlay.swift
//  MediStock
//
//  Created by Julien Cotte on 10/08/2026.
//

import SwiftUI

/// Full-screen dimmed background with a spinner, shown while a ViewModel action is in flight.
/// Deliberately minimal — revisited with a real design once `feat/visual-design`/branding lands.
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            ProgressView()
                .controlSize(.extraLarge)
                .tint(.accent)
        }
    }
}

#Preview {
    LoadingOverlay()
}
