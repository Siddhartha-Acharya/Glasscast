//
//  HomeContentView.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import SwiftUI
import Foundation
import Combine

struct HomeContentView: View {
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject var appSettings: AppSettings
    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel(
            weatherService: CachedWeatherService(
                weatherService: WeatherService(apiKey: AppConfig.weatherAPIKey)
            ),
            locationService: LocationService()
        ))
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
                        
                        if let weather = viewModel.currentWeather {
                            HomeHeaderView(
                                cityName: weather.location.name
                                )
                            WeatherCard(weather: weather)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            
                            Spacer(minLength: 50)
                            
                            if let forecast = viewModel.forecast {
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
        .refreshable {
            await viewModel.refreshAll()
        }
        .onAppear {
            if viewModel.currentWeather == nil {
                Task {
                    await viewModel.refreshAll()
                }
            }
        }
    }
}

struct HomeHeaderView: View {
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

            NavigationLink {
                SearchCityView()
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.title3)
                    .frame(width: 36, height: 36)
                    .glassEffect()
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
}



