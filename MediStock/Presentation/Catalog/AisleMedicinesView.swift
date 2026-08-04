//
//  AisleMedicinesView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI

struct AisleMedicinesView: View {
    @ObservedObject var viewModel = CatalogViewModel()
    var aisle: String

    var body: some View {
        List {
            ForEach(viewModel.medicines.filter { $0.aisle == aisle }, id: \.id) { medicine in
                NavigationLink(destination: MedicineDetailView(medicine: medicine)) {
                    VStack(alignment: .leading) {
                        Text(medicine.name)
                            .font(.headline)
                        Text("Stock: \(medicine.stock)")
                            .font(.subheadline)
                    }
                }
            }
        }
        .navigationBarTitle(aisle)
        .onAppear {
            viewModel.fetchMedicines()
        }
    }
}

struct MedicineListView_Previews: PreviewProvider {
    static var previews: some View {
        AisleMedicinesView(aisle: "Aisle 1").environmentObject(AuthenticationViewModel(authenticationService: FirebaseAuthenticationService()))
    }
}
