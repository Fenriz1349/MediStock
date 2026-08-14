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
    @State private var formViewModel: MedicineFormViewModel?
    @State private var isPresentingDeleteConfirmation = false
    @EnvironmentObject var toasty: ToastyManager
    @Environment(\.diContainer) private var container
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text(viewModel.medicine.name)
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                    .padding(.top, 20)
                    .padding(.horizontal)
                    .accessibilityHidden(formViewModel == nil)

                // Medicine Name & Aisle
                if let formViewModel {
                    MedicineFormContent(viewModel: formViewModel)

                    Button(action: {
                        Task {
                            let cleanedAisle = AisleCode.stripLabel(AisleLabel.localized, from: formViewModel.aisle)
                            if let saved = await formViewModel.save(cleanedAisle: cleanedAisle) {
                                viewModel.applyUpdate(saved)
                                self.formViewModel = nil
                            }
                        }
                    }, label: {
                        Text("medicineDetail.saveButton")
                    })
                    .buttonStyle(AppButtonStyle())
                    .disabled(!formViewModel.isFormValid)
                    .padding(.horizontal)
                } else {
                    let formattedAisle = AisleCode.format(code: viewModel.medicine.aisle,
                                                           aisleLabel: AisleLabel.localized)
                    Text(formattedAisle)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .accessibilityLabel(
                            AccessibilityHandler.MedicineDetail.summary(
                                name: viewModel.medicine.name, aisle: formattedAisle, stock: viewModel.medicine.stock
                            )
                        )
                }

                // Medicine Stock
                MedicineDetailStockSection(
                    stock: viewModel.medicine.stock,
                    onIncrease: { Task { await viewModel.increase() } },
                    onDecrease: { Task { await viewModel.decrease() } },
                    stockValueAccessibilityHidden: formViewModel == nil
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
        .navigationBarTitle(viewModel.medicine.name, displayMode: .inline)
        .toolbar {
            if let formViewModel {
                ToolbarItem(placement: .cancellationAction) {
                    Button("addMedicine.cancelButton") {
                        self.formViewModel = nil
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("medicineDetail.saveButton") {
                        Task {
                            let cleanedAisle = AisleCode.stripLabel(AisleLabel.localized, from: formViewModel.aisle)
                            if let saved = await formViewModel.save(cleanedAisle: cleanedAisle) {
                                viewModel.applyUpdate(saved)
                                self.formViewModel = nil
                            }
                        }
                    }
                    .disabled(!formViewModel.isFormValid)
                }
                KeyboardToolBar(isValidateEnabled: formViewModel.isFormValid) {
                    Task {
                        let cleanedAisle = AisleCode.stripLabel(AisleLabel.localized, from: formViewModel.aisle)
                        if let saved = await formViewModel.save(cleanedAisle: cleanedAisle) {
                            viewModel.applyUpdate(saved)
                            self.formViewModel = nil
                        }
                    }
                }
            } else {
                ToolbarItem(placement: .primaryAction) {
                    Button("medicineDetail.editButton") {
                        formViewModel = container.makeMedicineFormViewModel(existingMedicine: viewModel.medicine)
                    }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        isPresentingDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel(AccessibilityHandler.DeleteButton.label(name: viewModel.medicine.name))
                }
            }
        }
        .alert(
            "medicine.delete.confirmTitle",
            isPresented: $isPresentingDeleteConfirmation
        ) {
            Button("medicine.delete.confirmButton", role: .destructive) {
                Task { await viewModel.delete() }
            }
            Button("medicine.delete.cancelButton", role: .cancel) {}
        } message: {
            Text("medicine.delete.confirmMessage")
        }
        .onAppear {
            viewModel.listen()
        }
        .onChange(of: viewModel.error) { _, error in
            if let error {
                toasty.showError(error.localizedMessage)
            }
        }
        .onChange(of: formViewModel?.error) { _, error in
            if let error = error ?? nil {
                toasty.showError(error.localizedMessage)
            }
        }
        .onChange(of: viewModel.isDeleted) { _, isDeleted in
            if isDeleted {
                dismiss()
            }
        }
    }
}

struct MedicineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = PreviewHelper.container.makeMedicineDetailViewModel(medicine: PreviewHelper.sampleMedicine)
        MedicineDetailView(viewModel: viewModel)
            .environmentObject(ToastyManager())
            .environment(\.diContainer, PreviewHelper.container)
    }
}
