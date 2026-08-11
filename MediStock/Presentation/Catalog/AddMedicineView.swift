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
    @StateObject var viewModel: AddMedicineViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                MedicineFormContent(viewModel: viewModel)

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
            .navigationBarItems(
                leading: Button("addMedicine.cancelButton") { dismiss() },
                trailing: Button("addMedicine.saveButton") {
                    let cleanedAisle = AisleCode.stripLabel(AisleLabel.localized, from: viewModel.aisle)
                    Task {
                        await viewModel.save(cleanedAisle: cleanedAisle)
                        if viewModel.error == nil {
                            dismiss()
                        }
                    }
                }
                .disabled(!viewModel.isFormValid)
            )
        }
        .overlay {
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
    }
}

#Preview {
    AddMedicineView(viewModel: DIContainer().makeAddMedicineViewModel())
}
