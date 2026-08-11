//
//  MedicineDetailView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI
import Toasty

struct MedicineDetailView: View {
    @StateObject var viewModel: MedicineDetailViewModel
    @State private var isEditing = false
    @EnvironmentObject var toasty: ToastyManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text(viewModel.medicine.name)
                    .font(.largeTitle)
                    .padding(.top, 20)

                // Medicine Name & Aisle
                if isEditing {
                    MedicineFormContent(name: $viewModel.name,
                                        aisle: $viewModel.aisle,
                                        nameState: $viewModel.nameState,
                                        aisleState: $viewModel.aisleState)
                } else {
                    Text(AisleCode.format(code: viewModel.medicine.aisle, aisleLabel: AisleLabel.localized))
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }

                // Medicine Stock
                MedicineDetailStockSection(
                    stock: viewModel.medicine.stock,
                    onIncrease: { Task { await viewModel.increase() } },
                    onDecrease: { Task { await viewModel.decrease() } }
                )

                // History Section
                MedicineDetailHistorySection(history: viewModel.history)
            }
            .padding(.vertical)
        }
        .overlay {
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
        .navigationBarTitle("medicineDetail.navigationTitle", displayMode: .inline)
        .toolbar {
            if isEditing {
                ToolbarItem(placement: .cancellationAction) {
                    Button("addMedicine.cancelButton") {
                        isEditing = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("medicineDetail.saveButton") {
                        Task {
                            let cleanedAisle = AisleCode.stripLabel(AisleLabel.localized, from: viewModel.aisle)
                            await viewModel.updateLabel(name: viewModel.name, aisle: cleanedAisle)
                            if viewModel.error == nil {
                                isEditing = false
                            }
                        }
                    }
                    .disabled(!viewModel.isFormValid)
                }
            } else {
                ToolbarItem(placement: .primaryAction) {
                    Button("medicineDetail.editButton") {
                        viewModel.beginEditing()
                        isEditing = true
                    }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.delete()
                            if viewModel.error == nil {
                                dismiss()
                            }
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .onAppear {
            viewModel.listen()
        }
        .onChange(of: viewModel.error) { _, error in
            if let error {
                toasty.showError(error.localizedMessage)
            }
        }
    }
}

struct MedicineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMedicine = Medicine(name: "Sample", stock: 10, aisle: "Aisle 1")
        MedicineDetailView(viewModel: DIContainer().makeMedicineDetailViewModel(medicine: sampleMedicine))
            .environmentObject(ToastyManager())
    }
}
