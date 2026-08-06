//
//  AisleListView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI

struct AisleListView: View {
    @EnvironmentObject var viewModel: CatalogViewModel
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    @State private var isPresentingAddMedicine = false

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.aisles, id: \.self) { aisle in
                    NavigationLink(destination: AisleMedicinesView(aisle: aisle)) {
                        Text(AisleCode.format(code: aisle, aisleLabel: String(localized: "medicineDetail.aisle.label")))
                    }
                }
            }
            .navigationBarTitle("tab.aisles.title")
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

struct AisleListView_Previews: PreviewProvider {
    static var previews: some View {
        let medicineStore = FirestoreMedicineStore()
        AisleListView()
            .environmentObject(CatalogViewModel(medicineStore: medicineStore, historyStore: FirestoreHistoryStore()))
            .environmentObject(AuthenticationViewModel(authenticationService: FirebaseAuthenticationService()))
    }
}
