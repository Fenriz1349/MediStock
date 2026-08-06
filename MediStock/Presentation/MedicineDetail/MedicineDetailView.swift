//
//  MedicineDetailView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI

struct MedicineDetailView: View {
    @State var medicine: Medicine
    @StateObject private var viewModel = MedicineDetailViewModel(medicineStore: FirestoreMedicineStore(), historyStore: FirestoreHistoryStore())
    @EnvironmentObject var catalogViewModel: CatalogViewModel
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss

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
                await catalogViewModel.delete(medicine)
                dismiss()
            }
        }) {
            Image(systemName: "trash")
                .foregroundColor(.red)
        })
        .onAppear {
            viewModel.listen(forMedicineId: medicine.id ?? "")
        }
        .onChange(of: medicine) { _ in
            var cleaned = medicine
            cleaned.aisle = AisleCode.stripLabel(String(localized: "medicineDetail.aisle.label"), from: medicine.aisle)
            Task { await viewModel.updateMedicine(cleaned, user: authenticationViewModel.session?.uid ?? "") }
        }
    }
}

extension MedicineDetailView {
    private var medicineStockSection: some View {
        VStack(alignment: .leading) {
            Text("medicineDetail.stock.label")
                .font(.headline)
            HStack {
                Button(action: {
                    Task { await viewModel.decreaseStock(medicine, user: authenticationViewModel.session?.uid ?? "") }
                }) {
                    Image(systemName: "minus.circle")
                        .font(.title)
                        .foregroundColor(.red)
                }
                TextField("medicineDetail.stock.label", value: $medicine.stock, formatter: NumberFormatter())
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(width: 100)
                Button(action: {
                    Task { await viewModel.increaseStock(medicine, user: authenticationViewModel.session?.uid ?? "") }
                }) {
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
            .environmentObject(CatalogViewModel(medicineStore: FirestoreMedicineStore(), historyStore: FirestoreHistoryStore()))
            .environmentObject(AuthenticationViewModel(authenticationService: FirebaseAuthenticationService()))
    }
}
