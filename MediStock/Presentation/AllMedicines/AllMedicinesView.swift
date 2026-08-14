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
    @EnvironmentObject private var toasty: ToastyManager

    @State private var isPresentingAddMedicine = false
    @State private var navigationPath: [Medicine] = []
    @State private var pendingDeletion: Medicine?

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                if viewModel.medicines.isEmpty {
                    Text("allMedicines.noResults")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.medicines, id: \.id) { medicine in
                        Button {
                            navigationPath.append(medicine)
                        } label: {
                            AccentListRow(
                                heading: medicine.name,
                                caption: String(
                                    localized: "allMedicines.medicineStock",
                                    defaultValue: "Stock : \(medicine.stock)"
                                ),
                                accentColor: medicine.stock == 0
                                    ? .secondary
                                    : .accentColor,
                                accessibilityLabel: AccessibilityHandler.MedicineRow.label(
                                    name: medicine.name,
                                    stock: medicine.stock
                                )
                            )
                        }
                        .buttonStyle(.plain)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .onAppear {
                            if medicine.id == viewModel.medicines.last?.id {
                                viewModel.loadMore()
                            }
                        }
                    }
                    .onDelete { indexSet in
                        pendingDeletion = indexSet.first.map { viewModel.medicines[$0] }
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
            .overlay(alignment: .bottomTrailing) {
                // No sort menu while searching — a name-prefix search already returns a small,
                // name-ordered result set, so sorting it has no real use.
                if viewModel.filterText.isEmpty {
                    SortingMenu(
                        sortOption: $viewModel.sortOption,
                        sortAscending: $viewModel.sortAscending
                    )
                    .padding()
                }
            }
            .navigationBarTitle("tab.allMedicines.title", displayMode: .inline)
            .searchable(
                text: $viewModel.filterText,
                placement: .toolbar,
                prompt: Text("allMedicines.filterField")
            )
            .navigationDestination(for: Medicine.self) { medicine in
                MedicineDetailView(
                    viewModel: container.makeMedicineDetailViewModel(
                        medicine: medicine
                    )
                )
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isPresentingAddMedicine = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel(
                        AccessibilityHandler.AddMedicineButton.label
                    )
                }
            }
            .sheet(isPresented: $isPresentingAddMedicine) {
                AddMedicineView(
                    viewModel: container.makeMedicineFormViewModel()
                )
            }
            .alert(
                "medicine.delete.confirmTitle",
                isPresented: Binding(get: { pendingDeletion != nil }, set: { if !$0 { pendingDeletion = nil } })
            ) {
                Button("medicine.delete.confirmButton", role: .destructive) {
                    if let pendingDeletion {
                        Task { await viewModel.delete(pendingDeletion) }
                    }
                }
                Button("medicine.delete.cancelButton", role: .cancel) {}
            } message: {
                Text("medicine.delete.confirmMessage")
            }
            .onAppear {
                viewModel.listen()
            }
            .onChange(of: viewModel.error) { _, error in
                if let error {
                    toasty.showError(error.localizedMessage)
                }
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
