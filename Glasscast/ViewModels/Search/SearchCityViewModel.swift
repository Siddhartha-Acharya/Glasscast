//
//  SearchCityViewModel.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import Foundation
import Supabase
import SwiftUI
import Combine

@MainActor
final class SearchCityViewModel: ObservableObject {

    @Published var results: [Location] = []
    @Published var favorites: [FavoriteCity] = []

    private let weatherService: WeatherServiceProtocol
    private let favoritesService: FavoriteCitiesServiceProtocol

    init(
        weatherService: WeatherServiceProtocol,
        favoritesService: FavoriteCitiesServiceProtocol
    ) {
        self.weatherService = weatherService
        self.favoritesService = favoritesService
    }

    func loadFavorites() async {
        favorites = (try? await favoritesService.fetchFavorites()) ?? []
    }

    func isFavorite(_ location: Location) -> Bool {
        favorites.contains { $0.city_name == location.name }
    }

    func search(query: String) async {
        do {
            results = try await weatherService.searchLocations(query: query)
            await loadFavorites()
        }catch(let err) {
            print(err.localizedDescription)
        }
    }

    func addFavorite(_ location: Location) async {
        try? await favoritesService.addFavorite(location: location)
        await loadFavorites()
    }
}


