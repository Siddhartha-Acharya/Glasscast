//
//  FavoriteCitiesServiceProtocol.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import SwiftUI
import Supabase
import Foundation
import Combine

protocol FavoriteCitiesServiceProtocol {
    func fetchFavorites() async throws -> [FavoriteCity]
    func addFavorite(location: Location) async throws
}

final class FavoriteCitiesService: FavoriteCitiesServiceProtocol {

    private let client = DIContainer.shared.supabaseClient

    func fetchFavorites() async throws -> [FavoriteCity] {
        let session = try await client.auth.session

        let response: [FavoriteCity] = try await client
            .from("favorite_cities")
            .select()
            .eq("user_id", value: session.user.id)
            .execute()
            .value

        return response
    }

    func addFavorite(location: Location) async throws {
        let session = try await client.auth.session

        let insert = FavoriteCityInsert(
            user_id: session.user.id,
            city_name: location.name,
            lat: location.latitude,
            lon: location.longitude
        )

        try await client
            .from("favorite_cities")
            .insert(insert)
            .execute()
    }
}

@MainActor
final class FavoritesViewModel: ObservableObject {

    @Published var favorites: [FavoriteCity] = []
    @Published var weatherByCity: [UUID: Weather] = [:]
    @Published var isLoading = false

    private let favoritesService: FavoriteCitiesServiceProtocol
    private let weatherService: WeatherServiceProtocol

    init(
        favoritesService: FavoriteCitiesServiceProtocol,
        weatherService: WeatherServiceProtocol
    ) {
        self.favoritesService = favoritesService
        self.weatherService = weatherService
    }

    func loadFavorites() async {
        isLoading = true
        defer { isLoading = false }

        do {
            favorites = try await favoritesService.fetchFavorites()
            await fetchWeather()
        } catch {
            print("❌ Favorites load error:", error.localizedDescription)
        }
    }

    private func fetchWeather() async {
        weatherByCity = [:]

        for city in favorites {
            do {
                let weather = try await weatherService.getCurrentWeather(
                    latitude: city.lat,
                    longitude: city.lon
                )
                weatherByCity[city.id] = weather
            } catch {
                print("❌ Weather fetch failed:", city.city_name)
            }
        }
    }
}
