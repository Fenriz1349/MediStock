//
//  MedicineFormContent.swift
//  MediStock
//
//  Created by Julien Cotte on 06/08/2026.
//

import SwiftUI
import CustomTextFields

/// Shared name/aisle/stock fields, embedded in both the add-medicine and medicine-detail screens.
/// Not a standalone navigable screen — just the common form content.
/// This view only renders the fields, it never triggers a save itself.
struct MedicineFormContent: View {
    @ObservedObject var viewModel: MedicineFormViewModel

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

            // Stock only makes sense when creating — editing goes through the +/- steppers instead.
            if viewModel.existingMedicine == nil {
                CustomTextField.triggered(
                    placeholder: String(localized: "medicineDetail.stock.label"),
                    text: $viewModel.stockText,
                    type: .number,
                    validator: MedicinePolicy.isValidStock,
                    errorMessage: String(localized: "medicineDetail.stock.invalidFormat"),
                    validationState: $viewModel.stockState
                )
                .onChange(of: viewModel.stockText) {
                    viewModel.sanitizeStock()
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    Form {
        MedicineFormContent(viewModel: PreviewHelper.container.makeMedicineFormViewModel())
    }
}
