//
//  FavoriteWeatherDetailView.swift
//  Glasscast
//
//  Created by selegic mac 01 on 20/01/26.
//

import SwiftUI

struct FavoriteWeatherDetailView: View {

    let favorite: FavoriteCity

    @StateObject private var vm: FavoriteWeatherDetailViewModel

    init(favorite: FavoriteCity) {
        self.favorite = favorite
        _vm = StateObject(
            wrappedValue: FavoriteWeatherDetailViewModel(
                favorite: favorite,
                weatherService: DIContainer.shared.weatherService
            )
        )
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            GlassEffectContainer {
                ScrollView {
                    VStack(spacing: 24) {
                        
                        if let weather = vm.weather {
                            FavHeaderView(
                                cityName: weather.location.name
                                )
                            WeatherCard(weather: weather)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            
                            Spacer(minLength: 50)
                            
                            if let forecast = vm.forecast {
                                HStack {
                                    Text("5-DAYS FORECAST")
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(forecast.dailyForecasts.prefix(5)) { day in
                                            ForecastSection(forecast: day)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            await vm.load()
        }
    }
}

struct FavHeaderView: View {
    let cityName: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("CURRENT LOCATION")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(cityName)
                    .font(.title2.weight(.semibold))
            }

            Spacer()

        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
}



