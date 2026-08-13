//
//  AisleMedicinesView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI

struct AisleMedicinesView: View {
    @StateObject var viewModel: AisleMedicinesViewModel

    var body: some View {
        List {
            ForEach(viewModel.medicines, id: \.id) { medicine in
                NavigationLink(value: medicine) {
                    AccentListRow(
                        heading: medicine.name,
                        caption: String(localized: "allMedicines.medicineStock",
                                        defaultValue: "Stock : \(medicine.stock)"),
                        accentColor: medicine.stock == 0 ? .secondary : .accentColor,
                        accessibilityLabel: AccessibilityHandler.MedicineRow.label(
                            name: medicine.name, stock: medicine.stock
                        )
                    )
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            }
            .listRowBackground(Color.clear)
        }
        .overlay(alignment: .bottomTrailing) {
            SortingMenu(sortOption: $viewModel.sortOption, sortAscending: $viewModel.sortAscending)
                .padding()
        }
        .navigationBarTitle(
            AisleCode.format(code: viewModel.aisle, aisleLabel: AisleLabel.localized),
            displayMode: .inline
        )
        .onAppear {
            viewModel.listen()
        }
    }
}

struct AisleMedicinesView_Previews: PreviewProvider {
    static var previews: some View {
        let aisle = PreviewHelper.sampleMedicine.aisle
        AisleMedicinesView(viewModel: PreviewHelper.container.makeAisleMedicinesViewModel(aisle: aisle))
    }
}
