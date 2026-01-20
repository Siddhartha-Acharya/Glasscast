//
//  HomeViewModel.swift
//  Glasscast
//
//  Created by selegic mac 01 on 20/01/26.
//

import SwiftUI
import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var currentWeather: Weather?
    @Published var forecast: Forecast?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let weatherService: WeatherServiceProtocol
    let locationService: LocationServiceProtocol
    
    init(
        weatherService: WeatherServiceProtocol,
        locationService: LocationServiceProtocol
    ) {
        self.weatherService = weatherService
        self.locationService = locationService
    }
    
    // Example 1: Fetch weather by coordinates
    func fetchWeatherForCurrentLocation() async {
        isLoading = true
        errorMessage = nil

        do {
            let location = try await locationService.getCurrentLocation()
            print("📍 Location:", location)

            let weather = try await weatherService.getCurrentWeather(for: location)
            print("☀️ Weather OK")
            self.currentWeather = weather

            print("⏳ Calling forecast API...")
            let forecast = try await weatherService.getForecast(for: location)
            print("✅ Forecast received:", forecast)

            self.forecast = forecast

        } catch {
            print("❌ ERROR:", error)
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }


    
    func start() async {
        let authorized = await locationService.requestPermission()
        guard authorized else {
            errorMessage = "Location permission required"
            return
        }

        await fetchWeatherForCurrentLocation()
    }
    
    // Example 2: Fetch weather by city name
    func searchWeather(for city: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let weather = try await weatherService.getCurrentWeather(cityName: city)
            self.currentWeather = weather
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // Example 3: Fetch forecast
    func fetchForecast() async {
        guard let location = currentWeather?.location else { return }
        
        do {
            let forecast = try await weatherService.getForecast(for: location)
            self.forecast = forecast
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // Example 4: Search locations with autocomplete
    func searchLocations(query: String) async -> [Location] {
        do {
            return try await weatherService.searchLocations(query: query)
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }
    
    // Example 5: Refresh all data
    func refreshAll() async {
        await fetchWeatherForCurrentLocation()
    }
}

extension HomeViewModel {
    // Comprehensive error handling
    func fetchWeatherWithDetailedErrorHandling(city: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let weather = try await weatherService.getCurrentWeather(cityName: city)
            self.currentWeather = weather
            
        } catch let error as WeatherError {
            switch error {
            case .invalidAPIKey:
                errorMessage = "Configuration error. Please contact support."
            case .cityNotFound:
                errorMessage = "City '\(city)' not found. Please check spelling."
            case .rateLimitExceeded:
                errorMessage = "Too many requests. Please wait a moment."
            case .networkError:
                errorMessage = "No internet connection. Please check your network."
            case .decodingError:
                errorMessage = "Unable to process weather data."
            default:
                errorMessage = error.localizedDescription
            }
        } catch {
            errorMessage = "An unexpected error occurred."
        }
        
        isLoading = false
    }
    
    // Retry logic with exponential backoff
    func fetchWeatherWithRetry(maxRetries: Int = 3) async {
        var retryCount = 0
        var delay: TimeInterval = 1.0
        
        while retryCount < maxRetries {
            do {
                let location = try await locationService.getCurrentLocation()
                let weather = try await weatherService.getCurrentWeather(for: location)
                self.currentWeather = weather
                return // Success!
                
            } catch let error as WeatherError {
                if case .networkError = error {
                    retryCount += 1
                    if retryCount < maxRetries {
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        delay *= 2 // Exponential backoff
                    } else {
                        errorMessage = "Failed to fetch weather after \(maxRetries) attempts"
                    }
                } else {
                    errorMessage = error.localizedDescription
                    return // Don't retry for non-network errors
                }
            } catch {
                errorMessage = error.localizedDescription
                return
            }
        }
    }
}

@MainActor
final class CachedWeatherService: WeatherServiceProtocol {
    private let weatherService: WeatherServiceProtocol
    private var cache: [String: (weather: Weather, timestamp: Date)] = [:]
    private let cacheTimeout: TimeInterval = 600 // 10 minutes
    
    init(weatherService: WeatherServiceProtocol) {
        self.weatherService = weatherService
    }
    
    func getCurrentWeather(for location: Location) async throws -> Weather {
        let cacheKey = "\(location.latitude),\(location.longitude)"
        
        // Check cache
        if let cached = cache[cacheKey],
           Date().timeIntervalSince(cached.timestamp) < cacheTimeout {
            print("🎯 Cache hit for \(location.name)")
            return cached.weather
        }
        
        // Fetch from API
        print("🌐 Fetching from API for \(location.name)")
        let weather = try await weatherService.getCurrentWeather(for: location)
        
        // Update cache
        cache[cacheKey] = (weather, Date())
        
        return weather
    }
    
    func getCurrentWeather(latitude: Double, longitude: Double) async throws -> Weather {
        let location = Location(name: "Unknown", country: "", latitude: latitude, longitude: longitude)
        return try await getCurrentWeather(for: location)
    }
    
    func getCurrentWeather(cityName: String) async throws -> Weather {
        try await weatherService.getCurrentWeather(cityName: cityName)
    }
    
    func getForecast(for location: Location) async throws -> Forecast {
        try await weatherService.getForecast(for: location)
    }
    
    func getForecast(latitude: Double, longitude: Double) async throws -> Forecast {
        try await weatherService.getForecast(latitude: latitude, longitude: longitude)
    }
    
    func searchLocations(query: String) async throws -> [Location] {
        try await weatherService.searchLocations(query: query)
    }
    
    func clearCache() {
        cache.removeAll()
    }
}

enum AppConfig {
    static let weatherAPIKey: String = {
        guard let key = ProcessInfo.processInfo.environment["WEATHER_API_KEY"] else {
            fatalError("❌ WEATHER_API_KEY not set")
        }
        return key
    }()
}
