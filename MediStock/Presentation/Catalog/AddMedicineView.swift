//
//  AddMedicineView.swift
//  MediStock
//
//  Created by Julien Cotte on 06/08/2026.
//

import SwiftUI

/// Screen to create a new medicine, reached from the Catalog screens' "+" button.
struct AddMedicineView: View {
    @EnvironmentObject var catalogViewModel: CatalogViewModel
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var aisle = ""
    @State private var stock = 0

    var body: some View {
        NavigationView {
            Form {
                MedicineFormContent(name: $name, aisle: $aisle)

                VStack(alignment: .leading) {
                    Text("medicineDetail.stock.label")
                        .font(.headline)
                    TextField("medicineDetail.stock.label", value: $stock, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("addMedicine.navigationTitle", displayMode: .inline)
            .navigationBarItems(trailing: Button("addMedicine.saveButton") {
                let cleanedAisle = AisleCode.stripLabel(String(localized: "medicineDetail.aisle.label"), from: aisle)
                Task {
                    await catalogViewModel.addMedicine(
                        name: name,
                        stock: stock,
                        aisle: cleanedAisle,
                        user: authenticationViewModel.session?.uid ?? ""
                    )
                    dismiss()
                }
            })
        }
    }
}

#Preview {
    AddMedicineView()
        .environmentObject(CatalogViewModel(medicineStore: FirestoreMedicineStore(), historyStore: FirestoreHistoryStore()))
        .environmentObject(AuthenticationViewModel(authenticationService: FirebaseAuthenticationService()))
}
