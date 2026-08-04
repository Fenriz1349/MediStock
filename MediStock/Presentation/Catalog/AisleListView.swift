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

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.aisles, id: \.self) { aisle in
                    NavigationLink(destination: AisleMedicinesView(aisle: aisle)) {
                        Text(aisle)
                    }
                }
            }
            .navigationBarTitle("tab.aisles.title")
            .navigationBarItems(trailing: Button(action: {
                Task { await viewModel.addRandomMedicine(user: authenticationViewModel.session?.uid ?? "") }
            }) {
                Image(systemName: "plus")
            })
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
