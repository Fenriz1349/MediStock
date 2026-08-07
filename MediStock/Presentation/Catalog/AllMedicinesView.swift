//
//  AllMedicinesView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI
import Toasty

struct AllMedicinesView: View {
    @EnvironmentObject var viewModel: CatalogViewModel
    @Environment(\.diContainer) private var container
    @State private var filterText: String = ""
    @State private var sortOption: SortOption = .none
    @State private var isPresentingAddMedicine = false

    var body: some View {
        NavigationStack {
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
                        NavigationLink(value: medicine) {
                            VStack(alignment: .leading) {
                                Text(medicine.name)
                                    .font(.headline)
                                Text(String(localized: "allMedicines.medicineStock",
                                            defaultValue: "Stock : \(medicine.stock)"))
                                    .font(.subheadline)
                            }
                        }
                    }
                    .onDelete { offsets in
                        let medicines = viewModel.medicines(matching: filterText, sortedBy: sortOption)
                        Task {
                            for index in offsets {
                                await viewModel.delete(medicines[index])
                            }
                        }
                    }
                }
                .navigationBarTitle("tab.allMedicines.title")
                .navigationDestination(for: Medicine.self) { medicine in
                    MedicineDetailView(viewModel: container.makeMedicineDetailViewModel(medicine: medicine))
                }
                .navigationBarItems(trailing: Button(action: {
                    isPresentingAddMedicine = true
                }, label: {
                    Image(systemName: "plus")
                }))
                .sheet(isPresented: $isPresentingAddMedicine) {
                    AddMedicineView()
                        .environmentObject(viewModel)
                }
            }
        }
    }
}

struct AllMedicinesView_Previews: PreviewProvider {
    static var previews: some View {
        AllMedicinesView()
            .environmentObject(CatalogViewModel(medicineStore: FirestoreMedicineStore(),
                                                historyStore: FirestoreHistoryStore(authenticationService: FirebaseAuthenticationService())))
            .environmentObject(ToastyManager())
    }
}
