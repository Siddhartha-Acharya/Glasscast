//
//  FavoriteWeatherDetailViewModel.swift
//  Glasscast
//
//  Created by selegic mac 01 on 20/01/26.
//

import SwiftUI
import Supabase
import Foundation
import Combine

@MainActor
final class FavoriteWeatherDetailViewModel: ObservableObject {

    @Published var weather: Weather?
    @Published var forecast: Forecast?

    private let weatherService: WeatherServiceProtocol
    private let favorite: FavoriteCity

    init(
        favorite: FavoriteCity,
        weatherService: WeatherServiceProtocol
    ) {
        self.favorite = favorite
        self.weatherService = weatherService
    }

    func load() async {
        do {
            async let current = weatherService.getCurrentWeather(
                latitude: favorite.lat,
                longitude: favorite.lon
            )

            async let forecastData = weatherService.getForecast(
                latitude: favorite.lat,
                longitude: favorite.lon
            )

            weather = try await current
            forecast = try await forecastData

        } catch {
            print("❌ Failed loading favorite weather:", error.localizedDescription)
        }
    }
}
