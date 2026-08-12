//
//  MedicineFormContent.swift
//  MediStock
//
//  Created by Julien Cotte on 06/08/2026.
//

import SwiftUI
import CustomTextFields

/// Shared name/aisle fields, embedded in both the add-medicine and medicine-detail screens.
/// Not a standalone navigable screen — just the common form content.
/// Takes bindings instead of a specific ViewModel type.
/// So it stays reusable between screens backed by different ViewModels (`MedicineFormViewModel`,
/// `MedicineDetailViewModel`).
/// The source of truth is still always whichever ViewModel owns the bindings passed in.
/// This view only renders the fields, it never triggers a save itself.
struct MedicineFormContent: View {
    @Binding var name: String
    @Binding var aisle: String
    @Binding var nameState: ValidationState
    @Binding var aisleState: ValidationState

    var body: some View {
        VStack(alignment: .leading) {
            CustomTextField.triggered(
                placeholder: String(localized: "medicineDetail.name.label"),
                text: $name,
                type: .alphaNumber,
                validator: MedicinePolicy.isValidName,
                errorMessage: String(localized: "medicineDetail.name.invalidFormat"),
                validationState: $nameState
            )
            Text("medicineDetail.name.capitalizationHint")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)

            CustomTextField.triggered(
                placeholder: String(localized: "medicineDetail.aisle.label"),
                text: $aisle,
                type: .alphaNumber,
                validator: MedicinePolicy.isValidAisle,
                errorMessage: String(localized: "medicineDetail.aisle.invalidFormat"),
                validationState: $aisleState
            )
            .padding(.bottom, 10)
        }
        .padding(.horizontal)
    }
}

#Preview {
    Form {
        MedicineFormContent(name: .constant("Doliprane"),
                             aisle: .constant("AD56"),
                             nameState: .constant(.valid),
                             aisleState: .constant(.valid))
    }
}
