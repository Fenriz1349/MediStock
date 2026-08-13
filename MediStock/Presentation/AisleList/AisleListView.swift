//
//  AisleListView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI
import Toasty

struct AisleListView: View {
    @StateObject var viewModel: AisleListViewModel
    @Environment(\.diContainer) private var container
    @State private var isPresentingAddMedicine = false

    var body: some View {
        NavigationStack {
            List {
                if viewModel.aisles.isEmpty {
                    Text("aisleList.noResults")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.aisles, id: \.self) { aisle in
                        NavigationLink(value: aisle) {
                            let formattedAisle = AisleCode.format(code: aisle, aisleLabel: AisleLabel.localized)
                            AccentListRow(
                                heading: formattedAisle,
                                caption: String(
                                    localized: "aisleList.medicineCount",
                                    defaultValue: "\(viewModel.medicineCount(forAisle: aisle)) médicaments"
                                ),
                                accentColor: .primary,
                                accessibilityLabel: AccessibilityHandler.AisleRow.label(
                                    aisle: formattedAisle, medicineCount: viewModel.medicineCount(forAisle: aisle)
                                )
                            )
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button(action: {
                    viewModel.sortAscending.toggle()
                }, label: {
                    Image(systemName: viewModel.sortAscending ? "arrow.up" : "arrow.down")
                })
                .buttonStyle(CircleIconButtonStyle())
                .accessibilityLabel(AccessibilityHandler.SortButton.label(ascending: viewModel.sortAscending))
                .padding()
            }
            .navigationBarTitle("tab.aisles.title", displayMode: .inline)
            .searchable(text: $viewModel.filterText, prompt: Text("aisleList.filterField"))
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
            .navigationDestination(for: String.self) { aisle in
                AisleMedicinesView(viewModel: container.makeAisleMedicinesViewModel(aisle: aisle))
            }
            .navigationDestination(for: Medicine.self) { medicine in
                MedicineDetailView(viewModel: container.makeMedicineDetailViewModel(medicine: medicine))
            }
            .onAppear {
                viewModel.listen()
            }
        }
    }
}

struct AisleListView_Previews: PreviewProvider {
    static var previews: some View {
        AisleListView(viewModel: PreviewHelper.container.makeAisleListViewModel())
            .environmentObject(ToastyManager())
            .environment(\.diContainer, PreviewHelper.container)
    }
}
