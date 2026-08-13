//
//  MedicineDetailStockSection.swift
//  MediStock
//
//  Created by Julien Cotte on 07/08/2026.
//

import SwiftUI

/// Displays a medicine's stock and the +/- controls to change it. Pure display, no business logic.
/// The caller owns the current stock value and what happens on increase/decrease.
struct MedicineDetailStockSection: View {
    let stock: Int
    let onIncrease: () -> Void
    let onDecrease: () -> Void
    /// Hides the stock value from VoiceOver when it's already read as part of a summary elsewhere.
    var stockValueAccessibilityHidden = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("medicineDetail.stock.label")
                .font(.headline)
                .accessibilityHidden(stockValueAccessibilityHidden)
            HStack {
                Button(action: onDecrease, label: {
                    Image(systemName: "minus")
                })
                .buttonStyle(CircleIconButtonStyle())
                .disabled(stock == 0)
                .opacity(stock == 0 ? 0.4 : 1)
                .accessibilityLabel(AccessibilityHandler.StockButton.decreaseLabel(stock: stock))

                Text(stock, format: .number)
                    .font(.title2)
                    .frame(minWidth: 100)
                    .accessibilityHidden(stockValueAccessibilityHidden)

                Button(action: onIncrease, label: {
                    Image(systemName: "plus")
                })
                .buttonStyle(CircleIconButtonStyle())
                .accessibilityLabel(AccessibilityHandler.StockButton.increaseLabel(stock: stock))
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal)
    }
}

#Preview {
    MedicineDetailStockSection(stock: 10, onIncrease: {}, onDecrease: {})
}
