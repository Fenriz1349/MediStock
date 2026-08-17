//
//  MainTabView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI
import Toasty

struct MainTabView: View {
    @Environment(\.diContainer) private var container

    var body: some View {
        TabView {
            AisleListView(viewModel: container.makeAisleListViewModel())
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("tab.aisles.title")
                }
                .accessibilityIdentifier("tab.aisles")

            AllMedicinesView(viewModel: container.makeAllMedicinesViewModel())
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("tab.allMedicines.title")
                }
                .accessibilityIdentifier("tab.allMedicines")

            UserView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("tab.user.title")
                }
                .accessibilityIdentifier("tab.user")
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
