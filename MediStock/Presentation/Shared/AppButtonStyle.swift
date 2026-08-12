//
//  AppButtonStyle.swift
//  MediStock
//
//  Created by Julien Cotte on 12/08/2026.
//

import SwiftUI

/// Shared button style for every primary action in the app.
/// Only `color` changes between call sites — `.accentColor` by default, red for destructive actions
/// (delete, sign out, delete account).
/// Filled with `color` when enabled, so it reads as available/tappable.
/// Bordered and greyed out when disabled, so it reads as unavailable without disappearing entirely.
struct AppButtonStyle: ButtonStyle {
    var color: Color = .accentColor
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 44)
            .foregroundColor(isEnabled ? .white : .secondary)
            .background(isEnabled ? color : .clear)
            .overlay {
                if !isEnabled {
                    RoundedRectangle(cornerRadius: 12).stroke(Color.secondary, lineWidth: 1)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: isEnabled ? color.opacity(0.35) : .clear, radius: 6, y: 3)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 12) {
        Button("addMedicine.saveButton") {}
            .buttonStyle(AppButtonStyle())
        Button("addMedicine.saveButton") {}
            .buttonStyle(AppButtonStyle())
            .disabled(true)
        Button("user.deleteAccountButton") {}
            .buttonStyle(AppButtonStyle(color: .red))
    }
    .padding()
}
