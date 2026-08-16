//
//  MedicineFormContent.swift
//  MediStock
//
//  Created by Julien Cotte on 06/08/2026.
//

import SwiftUI
import CustomTextFields

/// Shared name/aisle/stock fields, embedded in both the add-medicine and medicine-detail screens.
/// Not a standalone navigable screen — just renders the fields, never triggers a save itself.
struct MedicineFormContent: View {
    @ObservedObject var viewModel: MedicineFormViewModel
    @State private var isNameFocused = false

    var body: some View {
        VStack(alignment: .leading) {
            CustomTextField.triggered(
                placeholder: String(localized: "medicineDetail.name.label"),
                text: $viewModel.name,
                type: .alphaNumber,
                validator: MedicinePolicy.isValidName,
                errorMessage: String(localized: "medicineDetail.name.invalidFormat"),
                validationState: $viewModel.nameState,
                isFocusedBinding: $isNameFocused
            )
            Text("medicineDetail.name.capitalizationHint")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)

            HStack {
                CustomTextField.triggered(
                    placeholder: String(localized: "medicineDetail.aisle.label"),
                    text: $viewModel.aisle,
                    type: .alphaNumber,
                    validator: MedicinePolicy.isValidAisle,
                    errorMessage: String(localized: "medicineDetail.aisle.invalidFormat"),
                    validationState: $viewModel.aisleState
                )
                .onChange(of: viewModel.aisle) {
                    viewModel.sanitizeAisle()
                }

                if !viewModel.availableAisles.isEmpty {
                    Menu {
                        ForEach(viewModel.availableAisles, id: \.self) { code in
                            Button(code) { viewModel.aisle = code }
                        }
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                    .buttonStyle(CircleIconButtonStyle())
                    .accessibilityLabel(AccessibilityHandler.AislePickerButton.label)
                }
            }
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
        .onAppear {
            viewModel.listenAisles()
            // Setting focus immediately on appear is unreliable when this view is presented in a
            // sheet (AddMedicineView): the view isn't yet first-responder-ready mid-presentation.
            Task {
                try? await Task.sleep(nanoseconds: 600_000_000)
                isNameFocused = true
            }
        }
    }
}

#Preview {
    Form {
        MedicineFormContent(viewModel: PreviewHelper.container.makeMedicineFormViewModel())
    }
}
