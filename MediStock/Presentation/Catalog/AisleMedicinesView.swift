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
                    VStack(alignment: .leading) {
                        Text(medicine.name)
                            .font(.headline)
                        Text(String(localized: "allMedicines.medicineStock", defaultValue: "Stock : \(medicine.stock)"))
                            .font(.subheadline)
                    }
                }
            }
        }
        .navigationBarTitle(AisleCode.format(code: viewModel.aisle, aisleLabel: AisleLabel.localized))
        .onAppear {
            viewModel.listen()
        }
    }
}

struct AisleMedicinesView_Previews: PreviewProvider {
    static var previews: some View {
        let aisle = PreviewHelper.sampleMedicine.aisle
        AisleMedicinesView(viewModel: PreviewHelper.container.makeAisleMedicinesViewModel(aisle: aisle))
            .environmentObject(PreviewHelper.container.makeCatalogViewModel())
    }
}
