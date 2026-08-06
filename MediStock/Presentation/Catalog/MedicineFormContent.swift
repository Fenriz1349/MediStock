//
//  MedicineFormContent.swift
//  MediStock
//
//  Created by Julien Cotte on 06/08/2026.
//

import SwiftUI

/// Shared name/aisle fields, embedded in both the add-medicine and medicine-detail screens.
/// Not a standalone navigable screen — just the common form content.
struct MedicineFormContent: View {
    @Binding var name: String
    @Binding var aisle: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("medicineDetail.name.label")
                .font(.headline)
            TextField("medicineDetail.name.label", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)

            HStack {
                Text("medicineDetail.aisle.label")
                    .font(.headline)
                TextField("medicineDetail.aisle.label", text: $aisle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal)
    }
}

#Preview {
    Form {
        MedicineFormContent(name: .constant("Doliprane"), aisle: .constant("AD56"))
    }
}
