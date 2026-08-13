//
//  AllMedicinesView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI
import Toasty

/// Full-catalog screen: lists every medicine, with server-side name search and sort.
struct AllMedicinesView: View {
    @StateObject var viewModel: AllMedicinesViewModel
    @Environment(\.diContainer) private var container
    @State private var isPresentingAddMedicine = false

    var body: some View {
        NavigationStack {
            List {
                if viewModel.medicines.isEmpty {
                    Text("allMedicines.noResults")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.medicines, id: \.id) { medicine in
                        ZStack {
                            AccentListRow(
                                heading: medicine.name,
                                caption: String(localized: "allMedicines.medicineStock",
                                                defaultValue: "Stock : \(medicine.stock)"),
                                accentColor: medicine.stock == 0 ? .secondary : .accentColor
                            )
                            .accessibilityHidden(true)

                            NavigationLink(value: medicine) { EmptyView() }
                                .opacity(0)
                                .accessibilityLabel(AccessibilityHandler.MedicineRow.label(
                                    name: medicine.name, stock: medicine.stock
                                ))
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                SortingMenu(sortOption: $viewModel.sortOption, sortAscending: $viewModel.sortAscending)
                    .padding()
            }
            .navigationBarTitle("tab.allMedicines.title", displayMode: .inline)
            .searchable(text: $viewModel.filterText, prompt: Text("allMedicines.filterField"))
            .navigationDestination(for: Medicine.self) { medicine in
                MedicineDetailView(viewModel: container.makeMedicineDetailViewModel(medicine: medicine))
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        isPresentingAddMedicine = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
            .sheet(isPresented: $isPresentingAddMedicine) {
                AddMedicineView(viewModel: container.makeMedicineFormViewModel())
            }
            .onAppear {
                viewModel.listen()
            }
        }
    }
}

struct AllMedicinesView_Previews: PreviewProvider {
    static var previews: some View {
        AllMedicinesView(viewModel: PreviewHelper.container.makeAllMedicinesViewModel())
            .environmentObject(ToastyManager())
            .environment(\.diContainer, PreviewHelper.container)
    }
}
