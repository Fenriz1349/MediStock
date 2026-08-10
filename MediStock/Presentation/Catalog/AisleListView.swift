//
//  AisleListView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI
import Toasty

struct AisleListView: View {
    @EnvironmentObject var catalogViewModel: CatalogViewModel
    @StateObject private var viewModel = DIContainer().makeAisleListViewModel()
    @Environment(\.diContainer) private var container
    @State private var isPresentingAddMedicine = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.aisles, id: \.self) { aisle in
                    NavigationLink(value: aisle) {
                        Text(AisleCode.format(code: aisle, aisleLabel: AisleLabel.localized))
                    }
                }
            }
            .navigationBarTitle("tab.aisles.title")
            .navigationBarItems(trailing: Button(action: {
                isPresentingAddMedicine = true
            }, label: {
                Image(systemName: "plus")
            }))
            .sheet(isPresented: $isPresentingAddMedicine) {
                AddMedicineView()
                    .environmentObject(catalogViewModel)
            }
            .navigationDestination(for: String.self) { aisle in
                AisleMedicinesView(viewModel: container.makeAisleMedicinesViewModel(aisle: aisle))
            }
            .navigationDestination(for: Medicine.self) { medicine in
                MedicineDetailView(viewModel: container.makeMedicineDetailViewModel(medicine: medicine))
            }
            .onAppear {
                viewModel.listen()
            }
        }
    }
}

struct AisleListView_Previews: PreviewProvider {
    static var previews: some View {
        let medicineStore = FirestoreMedicineStore()
        AisleListView()
            .environmentObject(CatalogViewModel(medicineStore: medicineStore,
                                                historyStore: FirestoreHistoryStore(authenticationService: FirebaseAuthenticationService())))
            .environmentObject(ToastyManager())
    }
}
