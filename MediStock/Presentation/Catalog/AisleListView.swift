//
//  AisleListView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI

struct AisleListView: View {
    @ObservedObject var viewModel = CatalogViewModel()

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
                viewModel.addRandomMedicine(user: "test_user") // Remplacez par l'utilisateur actuel
            }) {
                Image(systemName: "plus")
            })
        }
        .onAppear {
            viewModel.fetchAisles()
        }
    }
}

struct AisleListView_Previews: PreviewProvider {
    static var previews: some View {
        AisleListView()
    }
}
