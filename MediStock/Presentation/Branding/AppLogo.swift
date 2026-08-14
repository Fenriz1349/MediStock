//
//  AppLogo.swift
//  MediStock
//
//  Created by Julien Cotte on 12/08/2026.
//

import SwiftUI

/// "MediStock" wordmark, with the "o" replaced by a split-capsule glyph matching the App Icon.
/// Drawn in code (not an image asset), so it scales crisply and follows light/dark mode.
struct AppLogo: View {
    var size: CGFloat = 34
    /// Overridable when the background is fixed regardless of theme.
    /// For example, `LoadingOverlay`'s dimming layer is always dark.

    var body: some View {
        HStack {
            Text("MediSt")
            CapsuleGlyph(pillHeight: size * 0.5)
            Text("ck")
        }
        .font(.system(size: size, weight: .heavy, design: .rounded))
        .foregroundColor(.accentColor)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("MediStock")
    }
}

/// The split-capsule glyph standing in for the "o", matching the App Icon's shape.
/// `UnevenRoundedRectangle` rounds only the outer corners of each half — no custom `Path` needed.
private struct CapsuleGlyph: View {
    let pillHeight: CGFloat

    /// The pill's overall width if it weren't split, and the gap width.
    /// Both derived from `pillHeight`, to keep the same proportions as the App Icon regardless of `size`.
    /// Pill width ≈ 2.7× its height, gap ≈ 0.4× its height.
    private var pieceWidth: CGFloat { pillHeight * 1.15 }
    private var gap: CGFloat { pillHeight * 0.4 }
    private var radius: CGFloat { pillHeight / 2 }

    var body: some View {
        HStack(spacing: gap) {
            UnevenRoundedRectangle(cornerRadii: .init(topLeading: radius, bottomLeading: radius))
                .fill(Color.accentColor)
                .frame(width: pieceWidth, height: pillHeight)
            UnevenRoundedRectangle(cornerRadii: .init(bottomTrailing: radius, topTrailing: radius))
                .fill(Color.accentColor)
                .frame(width: pieceWidth, height: pillHeight)
        }
        .rotationEffect(.degrees(-60))
        .frame(width: pillHeight * 2.7, height: pillHeight * 2.7)
    }
}

#Preview {
    VStack(spacing: 24) {
        AppLogo()
        AppLogo(size: 48)
    }
    .padding()
}
