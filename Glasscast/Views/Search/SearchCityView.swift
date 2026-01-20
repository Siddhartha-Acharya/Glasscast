//
//  SearchCityView.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import SwiftUI
import Supabase

struct SearchCityView: View {

    @StateObject private var vm = SearchCityViewModel(
        weatherService: DIContainer.shared.weatherService,
        favoritesService: FavoriteCitiesService()
    )

    @State private var query = ""

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            GlassEffectContainer {
                VStack(alignment: .leading, spacing: 20) {

                    Text("Search")
                        .font(.title2.bold())

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)

                        TextField("Find a city…", text: $query)
                            .submitLabel(.search)
                            .onSubmit {
                                Task { await vm.search(query: query) }
                            }
                    }
                    .padding()
                    .glassEffect()
                    .clipShape(Capsule())

                    ScrollView {
                        VStack(spacing: 14) {
                            ForEach(vm.results) { location in
                                CitySearchRow(
                                    location: location,
                                    isFavorite: vm.isFavorite(location),
                                    onFavoriteTap: {
                                        Task { await vm.addFavorite(location) }
                                    }
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            .padding()
        }
        .task {
            await vm.loadFavorites()
        }
    }
}


struct CitySearchRow: View {
        let location: Location
        let isFavorite: Bool
        let onFavoriteTap: () -> Void

        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(location.name)
                    Text(location.country)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: onFavoriteTap) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? .red : .primary)
                }
            }
            .padding()
            .glassEffect()
            .clipShape(Capsule())
        }
    }
