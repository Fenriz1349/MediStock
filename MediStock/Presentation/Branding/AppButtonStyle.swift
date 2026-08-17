//
//  AppButtonStyle.swift
//  MediStock
//
//  Created by Julien Cotte on 12/08/2026.
//

import SwiftUI

/// Shared button style for every primary action in the app.
/// `.accentColor` by default, red for irreversible/destructive actions (delete medicine, delete account).
struct AppButtonStyle: ButtonStyle {
    var color: Color = .accentColor
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: configuration.isPressed)
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
