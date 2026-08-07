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
                medicineStockSection

                // History Section
                historySection
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
        .onChange(of: medicine) { _ in
            let cleanedAisle = AisleCode.stripLabel(String(localized: "medicineDetail.aisle.label"), from: medicine.aisle)
            Task { await viewModel.updateLabel(name: medicine.name, aisle: cleanedAisle) }
        }
    }
}

extension MedicineDetailView {
    private var medicineStockSection: some View {
        VStack(alignment: .leading) {
            Text("medicineDetail.stock.label")
                .font(.headline)
            HStack {
                Button(action: { Task { await viewModel.decrease() } }) {
                    Image(systemName: "minus.circle")
                        .font(.title)
                        .foregroundColor(.red)
                }
                Text(viewModel.medicine.stock, format: .number)
                    .font(.title2)
                    .frame(width: 100)
                Button(action: { Task { await viewModel.increase() } }) {
                    Image(systemName: "plus.circle")
                        .font(.title)
                        .foregroundColor(.green)
                }
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal)
    }

    private var historySection: some View {
        VStack(alignment: .leading) {
            Text("medicineDetail.history.title")
                .font(.headline)
                .padding(.top, 20)
            ForEach(viewModel.history, id: \.id) { entry in
                VStack(alignment: .leading, spacing: 5) {
                    Text(entry.action)
                        .font(.headline)
                    Text(String(localized: "medicineDetail.history.user", defaultValue: "Utilisateur : \(entry.user)"))
                        .font(.subheadline)
                    Text(String(localized: "medicineDetail.history.date", defaultValue: "Date : \(entry.timestamp.formatted())"))
                        .font(.subheadline)
                    Text(String(localized: "medicineDetail.history.details", defaultValue: "Détails : \(entry.details)"))
                        .font(.subheadline)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.bottom, 5)
            }
        }
        .padding(.horizontal)
    }
}

struct MedicineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMedicine = Medicine(name: "Sample", stock: 10, aisle: "Aisle 1")
        MedicineDetailView(medicine: sampleMedicine)
    }
}
