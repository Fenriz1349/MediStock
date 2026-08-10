//
//  AisleMedicinesView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI

struct AisleMedicinesView: View {
    @EnvironmentObject var catalogViewModel: CatalogViewModel
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
            .onDelete { offsets in
                let medicines = viewModel.medicines
                Task {
                    for index in offsets {
                        await catalogViewModel.delete(medicines[index])
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
        AisleMedicinesView(viewModel: DIContainer().makeAisleMedicinesViewModel(aisle: "Aisle 1"))
            .environmentObject(CatalogViewModel(medicineStore: FirestoreMedicineStore(),
                                                historyStore: FirestoreHistoryStore(authenticationService: FirebaseAuthenticationService()),
                                                networkMonitor: NetworkMonitor()))
    }
}
