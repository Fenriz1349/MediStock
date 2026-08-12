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

    var body: some View {
        VStack(alignment: .leading) {
            Text("medicineDetail.stock.label")
                .font(.headline)
            HStack {
                Button(action: onDecrease, label: {
                    Image(systemName: "minus")
                        .font(.title3)
                        .padding(14)
                        .background(Circle().fill(Color(.secondarySystemBackground)))
                })
                .disabled(stock == 0)
                .opacity(stock == 0 ? 0.4 : 1)

                Text(stock, format: .number)
                    .font(.title2)
                    .frame(width: 100)

                Button(action: onIncrease, label: {
                    Image(systemName: "plus")
                        .font(.title3)
                        .padding(14)
                        .background(Circle().fill(Color(.secondarySystemBackground)))
                })
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal)
    }
}

#Preview {
    MedicineDetailStockSection(stock: 10, onIncrease: {}, onDecrease: {})
}
