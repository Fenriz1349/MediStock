//
//  AllMedicinesView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI
import Toasty

/// Full-catalog screen: lists every medicine, with local name search and server-side sort.
struct AllMedicinesView: View {
    @EnvironmentObject var catalogViewModel: CatalogViewModel
    @StateObject private var viewModel = DIContainer().makeAllMedicinesViewModel()
    @Environment(\.diContainer) private var container
    @State private var isPresentingAddMedicine = false

    var body: some View {
        NavigationStack {
            VStack {
                // Filter and sort
                HStack {
                    TextField("allMedicines.filterField", text: $viewModel.filterText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading, 10)

                    Spacer()

                    Picker("allMedicines.sortPicker", selection: $viewModel.sortOption) {
                        Text("allMedicines.sortOption.none").tag(SortOption.none)
                        Text("allMedicines.sortOption.name").tag(SortOption.name)
                        Text("allMedicines.sortOption.stock").tag(SortOption.stock)
                    }
                    .pickerStyle(.segmented)

                    Button(action: {
                        viewModel.sortAscending.toggle()
                    }, label: {
                        Image(systemName: viewModel.sortAscending ? "arrow.up" : "arrow.down")
                    })
                    .disabled(viewModel.sortOption == .none)
                    .padding(.trailing, 10)
                }
                .padding(.top, 10)

                // Medicine list
                List {
                    ForEach(viewModel.filteredMedicines, id: \.id) { medicine in
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
                        let medicines = viewModel.filteredMedicines
                        Task {
                            for index in offsets {
                                await catalogViewModel.delete(medicines[index])
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
                        .environmentObject(catalogViewModel)
                }
                .onAppear {
                    viewModel.listen()
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
