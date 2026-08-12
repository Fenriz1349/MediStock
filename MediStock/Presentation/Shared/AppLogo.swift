//
//  AppLogo.swift
//  MediStock
//
//  Created by Julien Cotte on 12/08/2026.
//

import SwiftUI

/// "MediStock" wordmark, with the "o" replaced by the same split-capsule glyph as the App Icon.
/// Drawn in code rather than loaded from an image asset, so it scales crisply at any `size`.
/// Adapts to light/dark mode for free — the text follows `Color.primary`, the capsule follows
/// `Branding.accentColor`, both already theme-aware.
/// Used on the Authentication/Offline/Loading screens.
/// The catalog screens show a navigation title instead, they don't need the full wordmark.
struct AppLogo: View {
    var size: CGFloat = 34
    /// The text color. Defaults to `.primary` (adapts to light/dark).
    /// Overridable when the background is fixed regardless of theme.
    /// For example, `LoadingOverlay`'s dimming layer is always dark.
    var textColor: Color = .primary

    var body: some View {
        HStack {
            Text("MediSt")
            CapsuleGlyph(pillHeight: size * 0.5)
                .padding(.horizontal, size * 0.04)
            Text("ck")
        }
        .font(.system(size: size, weight: .heavy, design: .rounded))
        .foregroundColor(.accentColor)
    }
}

/// The split-capsule glyph standing in for the "o".
/// Matches the App Icon's exact shape: each half keeps the pill's rounding on its outer end.
/// Flat on the inner end facing the gap.
/// Not two small independently-rounded pieces, which read as two dots rather than half a capsule.
/// `UnevenRoundedRectangle` (iOS 16+) rounds only the two corners on the outer side.
/// Gives that shape directly, no custom `Path`/arc math needed.
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
        .rotationEffect(.degrees(-40))
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
