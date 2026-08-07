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
                NavigationLink(value: medicine) {
                    VStack(alignment: .leading) {
                        Text(medicine.name)
                            .font(.headline)
                        Text(String(localized: "allMedicines.medicineStock", defaultValue: "Stock : \(medicine.stock)"))
                            .font(.subheadline)
                    }
                }
            }
            .onDelete { offsets in
                let medicines = viewModel.medicines(inAisle: aisle)
                Task {
                    for index in offsets {
                        await viewModel.delete(medicines[index])
                    }
                }
            }
        }
        .navigationBarTitle(AisleCode.format(code: aisle, aisleLabel: AisleLabel.localized))
    }
}

struct AisleMedicinesView_Previews: PreviewProvider {
    static var previews: some View {
        AisleMedicinesView(aisle: "Aisle 1")
            .environmentObject(CatalogViewModel(medicineStore: FirestoreMedicineStore(),
                                                historyStore: FirestoreHistoryStore()))
    }
}
