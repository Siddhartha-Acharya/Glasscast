//
//  FavoritesContentView.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import SwiftUI

struct FavoritesContentView: View {

    @StateObject private var vm = FavoritesViewModel(
        favoritesService: FavoriteCitiesService(),
        weatherService: DIContainer.shared.weatherService
    )
    

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    HStack {
                        Text("Favorite cities")
                            .font(.title2.bold())
                            .foregroundColor(.gray)

                        Spacer()
                        
                    }

                    if vm.favorites.isEmpty {
                        Text("No saved cities")
                            .foregroundStyle(.secondary)
                            .padding(.top, 80)
                    }

                    ForEach(vm.favorites) { city in
                        if let weather = vm.weatherByCity[city.id] {
                            NavigationLink {
                                FavoriteWeatherDetailView(favorite: city)
                            } label: {
                                FavoriteCityGlassCard(weather: weather)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .task {
            await vm.loadFavorites()
        }
    }
}
