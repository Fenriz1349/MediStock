//
//  MedicineDetailHistorySection.swift
//  MediStock
//
//  Created by Julien Cotte on 07/08/2026.
//

import SwiftUI

/// Displays the list of history entries for a medicine. Pure display, no business logic.
struct MedicineDetailHistorySection: View {
    let history: [HistoryEntry]

    var body: some View {
        VStack(alignment: .leading) {
            Text("medicineDetail.history.title")
                .font(.headline)
                .padding(.top, 20)
            ForEach(history, id: \.id) { entry in
                VStack(alignment: .leading, spacing: 5) {
                    Text(entry.action)
                        .font(.headline)
                    Text(String(localized: "medicineDetail.history.user",
                                defaultValue: "Utilisateur : \(entry.user)"))
                        .font(.subheadline)
                    Text(String(localized: "medicineDetail.history.date",
                                defaultValue: "Date : \(entry.timestamp.formatted())"))
                        .font(.subheadline)
                    Text(String(localized: "medicineDetail.history.details",
                                defaultValue: "Détails : \(entry.details)"))
                        .font(.subheadline)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.bottom, 5)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    MedicineDetailHistorySection(history: [])
}
