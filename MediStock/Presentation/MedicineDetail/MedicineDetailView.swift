//
//  MedicineDetailView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI

struct MedicineDetailView: View {
    @StateObject var viewModel: MedicineDetailViewModel
    @State private var name = ""
    @State private var aisle = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text(name)
                    .font(.largeTitle)
                    .padding(.top, 20)

                // Medicine Name & Aisle
                MedicineFormContent(name: $name, aisle: $aisle)

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
        }) {
            Image(systemName: "trash")
                .foregroundColor(.red)
        })
        .onAppear {
            viewModel.listen()
            name = viewModel.medicine.name
            aisle = viewModel.medicine.aisle
        }
        .onChange(of: name) { _, newValue in save(name: newValue, aisle: aisle) }
        .onChange(of: aisle) { _, newValue in save(name: name, aisle: newValue) }
    }

    /// Skips the save triggered by `onAppear` seeding `name`/`aisle` from `viewModel.medicine`:
    /// that assignment is not a user edit, and comparing against the ViewModel's current values
    /// (rather than tracking a separate "has the user typed yet" flag) detects that reliably even
    /// though SwiftUI batches the seeding writes and their resulting onChange firing together.
    private func save(name: String, aisle: String) {
        let cleanedAisle = AisleCode.stripLabel(String(localized: "medicineDetail.aisle.label"), from: aisle)
        guard name != viewModel.medicine.name || cleanedAisle != viewModel.medicine.aisle else { return }
        Task { await viewModel.updateLabel(name: name, aisle: cleanedAisle) }
    }
}

struct MedicineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMedicine = Medicine(name: "Sample", stock: 10, aisle: "Aisle 1")
        MedicineDetailView(viewModel: DIContainer().makeMedicineDetailViewModel(medicine: sampleMedicine))
    }
}
