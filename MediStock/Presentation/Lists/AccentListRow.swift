//
//  AccentListRow.swift
//  MediStock
//
//  Created by Julien Cotte on 12/08/2026.
//

import SwiftUI

/// List row with a leading accent bar and heading, both driven by `accentColor`.
/// The caption always stays `.secondary`.
struct AccentListRow: View {
    let heading: String
    let caption: String
    var accentColor: Color = .accentColor
    /// A natural-sentence VoiceOver label (e.g. "Doliprane, stock de 42").
    /// Falls back to reading `heading`/`caption` as separate fragments when `nil`.
    var accessibilityLabel: String?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(heading)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(accentColor)
                Text(caption)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()

            Image(systemName: "chevron.right")
                   .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: accessibilityLabel == nil ? .combine : .ignore)
        .modifier(OptionalAccessibilityLabel(label: accessibilityLabel))
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Color(.secondarySystemBackground))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(accentColor)
                .frame(width: 6)
                .accessibilityHidden(true)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.separator), lineWidth: 0.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }
}

/// Applies `.accessibilityLabel` only when `label` is set, leaving the default combined reading untouched otherwise.
private struct OptionalAccessibilityLabel: ViewModifier {
    let label: String?

    func body(content: Content) -> some View {
        if let label {
            content.accessibilityLabel(label)
        } else {
            content
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        AccentListRow(heading: "AD56", caption: "12 médicaments")
        AccentListRow(heading: "Doliprane", caption: "Stock : 42", accentColor: .primary)
        AccentListRow(heading: "Aspirine", caption: "Stock : 0", accentColor: .secondary)
    }
    .padding()
}
