//
//  AllMedicinesView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI

struct AllMedicinesView: View {
    @EnvironmentObject var viewModel: CatalogViewModel
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    @State private var filterText: String = ""
    @State private var sortOption: SortOption = .none
    @State private var isPresentingAddMedicine = false

    var body: some View {
        NavigationView {
            VStack {
                // Filtrage et Tri
                HStack {
                    TextField("allMedicines.filterField", text: $filterText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading, 10)

                    Spacer()

                    Picker("allMedicines.sortPicker", selection: $sortOption) {
                        Text("allMedicines.sortOption.none").tag(SortOption.none)
                        Text("allMedicines.sortOption.name").tag(SortOption.name)
                        Text("allMedicines.sortOption.stock").tag(SortOption.stock)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.trailing, 10)
                }
                .padding(.top, 10)

                // Liste des Médicaments
                List {
                    ForEach(viewModel.medicines(matching: filterText, sortedBy: sortOption), id: \.id) { medicine in
                        NavigationLink(destination: MedicineDetailView(medicine: medicine)) {
                            VStack(alignment: .leading) {
                                Text(medicine.name)
                                    .font(.headline)
                                Text(String(localized: "allMedicines.medicineStock", defaultValue: "Stock : \(medicine.stock)"))
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .navigationBarTitle("tab.allMedicines.title")
                .navigationBarItems(trailing: Button(action: {
                    isPresentingAddMedicine = true
                }) {
                    Image(systemName: "plus")
                })
                .sheet(isPresented: $isPresentingAddMedicine) {
                    AddMedicineView()
                        .environmentObject(viewModel)
                        .environmentObject(authenticationViewModel)
                }
            }
        }
    }
}

struct AllMedicinesView_Previews: PreviewProvider {
    static var previews: some View {
        AllMedicinesView()
            .environmentObject(CatalogViewModel(medicineStore: FirestoreMedicineStore(), historyStore: FirestoreHistoryStore()))
            .environmentObject(AuthenticationViewModel(authenticationService: FirebaseAuthenticationService()))
    }
}
