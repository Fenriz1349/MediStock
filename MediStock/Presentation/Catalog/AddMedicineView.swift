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
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var aisle = ""
    @State private var stockText = ""

    var body: some View {
        NavigationView {
            Form {
                MedicineFormContent(name: $name, aisle: $aisle)

                VStack(alignment: .leading) {
                    Text("medicineDetail.stock.label")
                        .font(.headline)
                    TextField("medicineDetail.stock.label", text: $stockText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("addMedicine.navigationTitle", displayMode: .inline)
            .navigationBarItems(
                leading: Button("addMedicine.cancelButton") { dismiss() },
                trailing: Button("addMedicine.saveButton") {
                    let cleanedAisle = AisleCode.stripLabel(AisleLabel.localized, from: aisle)
                    Task {
                        await catalogViewModel.addMedicine(
                            name: name,
                            stock: Int(stockText) ?? 0,
                            aisle: cleanedAisle
                        )
                        if catalogViewModel.error == nil {
                            dismiss()
                        }
                    }
                }
            )
        }
    }
}

#Preview {
    AddMedicineView()
        .environmentObject(CatalogViewModel(medicineStore: FirestoreMedicineStore(),
                                            historyStore: FirestoreHistoryStore(authenticationService: FirebaseAuthenticationService()),
                                            networkMonitor: NetworkMonitor()))
}
