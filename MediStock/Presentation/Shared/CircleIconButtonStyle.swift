//
//  CircleIconButtonStyle.swift
//  MediStock
//
//  Created by Julien Cotte on 13/08/2026.
//

import SwiftUI

/// Shared style for icon-only buttons: a round, secondary-background circle behind the glyph.
/// `diameter` scales with Dynamic Type and is shared by every button, keeping sizes consistent.
struct CircleIconButtonStyle: ButtonStyle {
    @ScaledMetric private var diameter: CGFloat = 44

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3)
            .frame(width: diameter, height: diameter)
            .background(Circle().fill(Color(.secondarySystemBackground)))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

#Preview {
    HStack(spacing: 12) {
        Button(action: {}, label: { Image(systemName: "minus") })
            .buttonStyle(CircleIconButtonStyle())
        Button(action: {}, label: { Image(systemName: "plus") })
            .buttonStyle(CircleIconButtonStyle())
        Button(action: {}, label: { Image(systemName: "arrow.up") })
            .buttonStyle(CircleIconButtonStyle())
    }
    .padding()
}
