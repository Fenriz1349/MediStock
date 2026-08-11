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
/// Reads/writes `name`/`aisle`/`nameState`/`aisleState` directly on `viewModel` — no state of its own.
/// This view only renders the fields, it never triggers a save itself.
struct MedicineFormContent: View {
    @ObservedObject var viewModel: AddMedicineViewModel

    var body: some View {
        VStack(alignment: .leading) {
            CustomTextField.triggered(
                placeholder: String(localized: "medicineDetail.name.label"),
                text: $viewModel.name,
                type: .alphaNumber,
                validator: MedicinePolicy.isValidName,
                errorMessage: String(localized: "medicineDetail.name.invalidFormat"),
                validationState: $viewModel.nameState
            )
            Text("medicineDetail.name.capitalizationHint")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)

            CustomTextField.triggered(
                placeholder: String(localized: "medicineDetail.aisle.label"),
                text: $viewModel.aisle,
                type: .alphaNumber,
                validator: MedicinePolicy.isValidAisle,
                errorMessage: String(localized: "medicineDetail.aisle.invalidFormat"),
                validationState: $viewModel.aisleState
            )
            .padding(.bottom, 10)
        }
        .padding(.horizontal)
    }
}

#Preview {
    Form {
        MedicineFormContent(viewModel: DIContainer().makeAddMedicineViewModel())
    }
}
