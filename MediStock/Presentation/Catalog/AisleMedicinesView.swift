//
//  AisleMedicinesView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI

struct AisleMedicinesView: View {
    @EnvironmentObject var viewModel: CatalogViewModel
    var aisle: String

    var body: some View {
        List {
            ForEach(viewModel.medicines(inAisle: aisle), id: \.id) { medicine in
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
        .navigationBarTitle(aisle)
    }
}

struct AisleMedicinesView_Previews: PreviewProvider {
    static var previews: some View {
        AisleMedicinesView(aisle: "Aisle 1")
            .environmentObject(CatalogViewModel(medicineStore: FirestoreMedicineStore(), historyStore: FirestoreHistoryStore()))
    }
}
