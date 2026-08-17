//
//  MainTabView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI
import Toasty

/// SwiftUI derives each `UITabBarItem`'s accessibility identifier from its `Image`'s SF Symbol name.
/// Not from any `.accessibilityIdentifier` on the tab's content.
/// `MediStockUITests` matches tabs by these symbol names (e.g. `"square.grid.2x2"`).
/// Changing one would silently break that test.
struct MainTabView: View {
    @Environment(\.diContainer) private var container

    var body: some View {
        TabView {
            AisleListView(viewModel: container.makeAisleListViewModel())
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("tab.aisles.title")
                }

            AllMedicinesView(viewModel: container.makeAllMedicinesViewModel())
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("tab.allMedicines.title")
                }

            UserView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("tab.user.title")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(PreviewHelper.container.makeAuthenticationViewModel())
            .environmentObject(ToastyManager())
            .environment(\.diContainer, PreviewHelper.container)
    }
}
