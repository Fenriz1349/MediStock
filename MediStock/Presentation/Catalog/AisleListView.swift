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
            VStack {
                HStack {
                    TextField("aisleList.filterField", text: $viewModel.filterText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading, 10)

                    Spacer()

                    Button(action: {
                        viewModel.sortAscending.toggle()
                    }, label: {
                        Image(systemName: viewModel.sortAscending ? "arrow.up" : "arrow.down")
                    })
                    .padding(.trailing, 10)
                }
                .padding(.top, 10)

                List {
                    if viewModel.aisles.isEmpty {
                        Text("aisleList.noResults")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.aisles, id: \.self) { aisle in
                            NavigationLink(value: aisle) {
                                AccentListRow(
                                    heading: AisleCode.format(code: aisle, aisleLabel: AisleLabel.localized),
                                    caption: String(localized: "aisleList.medicineCount",
                                                    defaultValue: "\(viewModel.medicineCount(forAisle: aisle)) médicaments"),
                                    accentColor: .primary
                                )
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .navigationBarTitle("tab.aisles.title")
            .navigationBarItems(trailing: Button(action: {
                isPresentingAddMedicine = true
            }, label: {
                Image(systemName: "plus")
            }))
            .sheet(isPresented: $isPresentingAddMedicine) {
                AddMedicineView(viewModel: container.makeAddMedicineViewModel())
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
