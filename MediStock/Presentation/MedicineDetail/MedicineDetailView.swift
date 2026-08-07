//
//  MedicineDetailView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI

struct MedicineDetailView: View {
    @StateObject var viewModel: MedicineDetailViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text(viewModel.name)
                    .font(.largeTitle)
                    .padding(.top, 20)

                // Medicine Name & Aisle
                MedicineFormContent(name: $viewModel.name, aisle: $viewModel.aisle)

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
        .navigationBarTitle("medicineDetail.navigationTitle", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            Task {
                await viewModel.delete()
                dismiss()
            }
        }, label: {
            Image(systemName: "trash")
                .foregroundColor(.red)
        }))
        .onAppear {
            viewModel.listen()
        }
        .onChange(of: viewModel.name) { _, _ in
            viewModel.scheduleLabelSave(cleanedAisle: AisleCode.stripLabel(AisleLabel.localized, from: viewModel.aisle))
        }
        .onChange(of: viewModel.aisle) { _, newValue in
            viewModel.scheduleLabelSave(cleanedAisle: AisleCode.stripLabel(AisleLabel.localized, from: newValue))
        }
    }
}

struct MedicineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMedicine = Medicine(name: "Sample", stock: 10, aisle: "Aisle 1")
        MedicineDetailView(viewModel: DIContainer().makeMedicineDetailViewModel(medicine: sampleMedicine))
    }
}
