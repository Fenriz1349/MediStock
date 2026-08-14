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
                let localized = HistoryEntryLocalized(entry)
                VStack(alignment: .leading, spacing: 5) {
                    Text(localized.action)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(String(localized: "medicineDetail.history.user",
                                defaultValue: "Utilisateur : \(localized.user)"))
                        .font(.subheadline)
                    (Text(String(localized: "accessibility.historyEntry.datePrefix", defaultValue: "Date : "))
                        + Text(entry.timestamp, style: .date)
                        + Text(" ")
                        + Text(entry.timestamp, style: .time))
                        .font(.subheadline)
                    Text(String(localized: "medicineDetail.history.details",
                                defaultValue: "Détails : \(localized.details)"))
                        .font(.subheadline)
                }
                .accessibilityElement(children: .combine)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
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
