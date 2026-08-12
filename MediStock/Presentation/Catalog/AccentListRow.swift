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

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(heading)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(accentColor)
                Text(caption)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Color(.secondarySystemBackground))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(accentColor)
                .frame(width: 6)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.separator), lineWidth: 0.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
