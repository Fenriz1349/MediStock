//
//  LoadingView.swift
//  MediStock
//
//  Created by Julien Cotte on 12/08/2026.
//

import SwiftUI

/// Launch-time placeholder, shown while `ContentView` waits on the initial session check.
/// Wipes `AppLogo` in from the left, reading as the wordmark being written out.
struct LoadingView: View {
    @State private var revealProgress: CGFloat = 0

    var body: some View {
        AppLogo(size: 40)
            .mask(alignment: .leading) {
                GeometryReader { proxy in
                    Rectangle().frame(width: proxy.size.width * revealProgress)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2)) {
                    revealProgress = 1
                }
            }
    }
}

#Preview {
    LoadingView()
}
