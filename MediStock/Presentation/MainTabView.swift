//
//  MainTabView.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            AisleListView()
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("tab.aisles.title")
                }

            AllMedicinesView()
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
    }
}
