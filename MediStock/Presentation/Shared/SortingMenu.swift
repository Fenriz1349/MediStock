//
//  SortingMenu.swift
//  MediStock
//
//  Created by Julien Cotte on 12/08/2026.
//

import SwiftUI

/// Floating sort menu, shared by every screen listing medicines locally sortable by name/stock.
/// The trigger button shows the active field and direction.
struct SortingMenu: View {
    @Binding var sortOption: SortOption
    @Binding var sortAscending: Bool

    private var triggerLabelKey: String {
        switch sortOption {
        case .none: "allMedicines.sortOption.none"
        case .name: "allMedicines.sortOption.name"
        case .stock: "allMedicines.sortOption.stock"
        }
    }

    private var triggerIcon: String {
        guard sortOption != .none else { return "arrow.up.arrow.down" }
        return sortAscending ? "arrow.up" : "arrow.down"
    }

    var body: some View {
        Menu {
            Button {
                sortOption = .none
            } label: {
                if sortOption == .none {
                    Label("allMedicines.sortOption.none", systemImage: "checkmark")
                } else {
                    Text("allMedicines.sortOption.none")
                }
            }
            Button {
                sortOption = .name
                sortAscending = true
            } label: {
                if sortOption == .name && sortAscending {
                    Label("allMedicines.sortOption.nameAscending", systemImage: "checkmark")
                } else {
                    Label("allMedicines.sortOption.nameAscending", systemImage: "arrow.up")
                }
            }
            Button {
                sortOption = .name
                sortAscending = false
            } label: {
                if sortOption == .name && !sortAscending {
                    Label("allMedicines.sortOption.nameDescending", systemImage: "checkmark")
                } else {
                    Label("allMedicines.sortOption.nameDescending", systemImage: "arrow.down")
                }
            }
            Button {
                sortOption = .stock
                sortAscending = true
            } label: {
                if sortOption == .stock && sortAscending {
                    Label("allMedicines.sortOption.stockAscending", systemImage: "checkmark")
                } else {
                    Label("allMedicines.sortOption.stockAscending", systemImage: "arrow.up")
                }
            }
            Button {
                sortOption = .stock
                sortAscending = false
            } label: {
                if sortOption == .stock && !sortAscending {
                    Label("allMedicines.sortOption.stockDescending", systemImage: "checkmark")
                } else {
                    Label("allMedicines.sortOption.stockDescending", systemImage: "arrow.down")
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(LocalizedStringKey(triggerLabelKey))
                Image(systemName: triggerIcon)
            }
            .font(.headline)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(Capsule().fill(Color(.secondarySystemBackground)))
        }
    }
}

#Preview {
    @Previewable @State var sortOption: SortOption = .none
    @Previewable @State var sortAscending = true
    return SortingMenu(sortOption: $sortOption, sortAscending: $sortAscending)
}
