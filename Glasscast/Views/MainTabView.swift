//
//  MainTabView.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import SwiftUI

struct MainTabView: View {

    let authViewModel: AuthViewModel

    var body: some View {
        TabView {
            HomeContentView()
                .tabItem {
                    Label("Weather", systemImage: "cloud.sun.fill")
                }

            FavoritesContentView()
                .tabItem {
                    Label("Favorites", systemImage: "star.fill")
                }

            SettingsContentView(authViewModel: authViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

