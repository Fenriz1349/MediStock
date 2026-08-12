//
//  AddMedicineView.swift
//  MediStock
//
//  Created by Julien Cotte on 06/08/2026.
//

import SwiftUI
import CustomTextFields

/// Screen to create a new medicine, reached from the Catalog screens' "+" button.
struct AddMedicineView: View {
    @StateObject var viewModel: MedicineFormViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                MedicineFormContent(name: $viewModel.name,
                                     aisle: $viewModel.aisle,
                                     nameState: $viewModel.nameState,
                                     aisleState: $viewModel.aisleState)

                VStack(alignment: .leading) {
                    Text("medicineDetail.stock.label")
                        .font(.headline)
                    CustomTextField.triggered(
                        placeholder: String(localized: "medicineDetail.stock.label"),
                        text: $viewModel.stockText,
                        type: .number,
                        validator: MedicinePolicy.isValidStock,
                        errorMessage: String(localized: "medicineDetail.stock.invalidFormat"),
                        validationState: $viewModel.stockState
                    )
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("addMedicine.navigationTitle", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("addMedicine.cancelButton") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("addMedicine.saveButton") {
                        let cleanedAisle = AisleCode.stripLabel(AisleLabel.localized, from: viewModel.aisle)
                        Task {
                            await viewModel.save(cleanedAisle: cleanedAisle)
                            if viewModel.error == nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.isFormValid)
                }
                KeyboardToolBar(isValidateEnabled: viewModel.isFormValid) {
                    let cleanedAisle = AisleCode.stripLabel(AisleLabel.localized, from: viewModel.aisle)
                    Task {
                        await viewModel.save(cleanedAisle: cleanedAisle)
                        if viewModel.error == nil {
                            dismiss()
                        }
                    }
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
    }
}

#Preview {
    AddMedicineView(viewModel: PreviewHelper.container.makeAddMedicineViewModel())
}
