//
//  AisleMedicinesView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI
import Toasty

struct AisleMedicinesView: View {
    @StateObject var viewModel: AisleMedicinesViewModel
    /// Shared with the ancestor `NavigationStack` — `AisleListView` owns it, not this screen.
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject private var toasty: ToastyManager

    @State private var pendingDeletion: Medicine?

    var body: some View {
        List {
            ForEach(viewModel.medicines, id: \.id) { medicine in
                Button {
                    navigationPath.append(medicine)
                } label: {
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
                .buttonStyle(.plain)
                .accessibilityIdentifier("medicineRow.\(medicine.name)")
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .onAppear {
                    if medicine.id == viewModel.medicines.last?.id {
                        viewModel.loadMore()
                    }
                }
            }
            .onDelete { indexSet in
                pendingDeletion = indexSet.first.map { viewModel.medicines[$0] }
            }
            .listRowBackground(Color.clear)
        }
        .overlay {
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
        .overlay(alignment: .bottomTrailing) {
            SortingMenu(sortOption: $viewModel.sortOption, sortAscending: $viewModel.sortAscending)
                .padding()
        }
        .navigationBarTitle(
            AisleCode.format(code: viewModel.aisle, aisleLabel: AisleLabel.localized),
            displayMode: .inline
        )
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
        .onChange(of: viewModel.medicines) { oldValue, newValue in
            // The aisle just lost its last medicine (deleted from here or from the detail screen).
            // Nothing left to show — go back to the aisle list instead of an empty screen.
            if !oldValue.isEmpty, newValue.isEmpty, !navigationPath.isEmpty {
                navigationPath.removeLast()
            }
        }
    }
}

struct AisleMedicinesView_Previews: PreviewProvider {
    static var previews: some View {
        let aisle = PreviewHelper.sampleMedicine.aisle
        AisleMedicinesView(
            viewModel: PreviewHelper.container.makeAisleMedicinesViewModel(aisle: aisle),
            navigationPath: .constant(NavigationPath())
        )
        .environmentObject(ToastyManager())
    }
}
