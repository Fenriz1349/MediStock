//
//  MedicineDetailView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI

struct MedicineDetailView: View {
    @State private var medicine: Medicine
    @StateObject private var viewModel: MedicineDetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(medicine: Medicine) {
        _medicine = State(initialValue: medicine)
        _viewModel = StateObject(wrappedValue: MedicineDetailViewModel(
            medicine: medicine,
            medicineStore: FirestoreMedicineStore(),
            historyStore: FirestoreHistoryStore(),
            authenticationService: FirebaseAuthenticationService()
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text(medicine.name)
                    .font(.largeTitle)
                    .padding(.top, 20)

                // Medicine Name & Aisle
                MedicineFormContent(name: $medicine.name, aisle: $medicine.aisle)

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
        }
        .onChange(of: medicine) { oldValue, newValue in
            let cleanedAisle = AisleCode.stripLabel(String(localized: "medicineDetail.aisle.label"), from: newValue.aisle)
            Task { await viewModel.updateLabel(name: newValue.name, aisle: cleanedAisle) }
        }
    }
}

struct MedicineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMedicine = Medicine(name: "Sample", stock: 10, aisle: "Aisle 1")
        MedicineDetailView(medicine: sampleMedicine)
    }
}
