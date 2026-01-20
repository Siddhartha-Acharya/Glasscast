//
//  WeatherService.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import Foundation

// MARK: - Protocol

protocol WeatherServiceProtocol {
    func getCurrentWeather(for location: Location) async throws -> Weather
    func getCurrentWeather(latitude: Double, longitude: Double) async throws -> Weather
    func getCurrentWeather(cityName: String) async throws -> Weather
    func getForecast(for location: Location) async throws -> Forecast
    func getForecast(latitude: Double, longitude: Double) async throws -> Forecast
    func searchLocations(query: String) async throws -> [Location]
}

// MARK: - Weather Service Implementation

final class WeatherService: WeatherServiceProtocol {
    
    private let apiKey: String
    private let baseURL = "https://api.weatherapi.com/v1"
    private let geocodingURL = "https://api.openweathermap.org/geo/1.0"
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
        
        // Configure JSON decoder
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .useDefaultKeys
    }
    
    // MARK: - Current Weather
    
    func getCurrentWeather(for location: Location) async throws -> Weather {
        return try await getCurrentWeather(
            latitude: location.latitude,
            longitude: location.longitude
        )
    }
    
    func getCurrentWeather(latitude: Double, longitude: Double) async throws -> Weather {

        let endpoint = "\(baseURL)/current.json"

        var components = URLComponents(string: endpoint)
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: "\(latitude),\(longitude)")
        ]

        guard let url = components?.url else {
            throw WeatherError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw WeatherError.invalidResponse
            }

            let apiResponse = try JSONDecoder().decode(
                WeatherAPICurrentResponse.self,
                from: data
            )

            return apiResponse.toDomain()

        } catch let error as DecodingError {
            throw WeatherError.decodingError(error)
        } catch let error as URLError {
            throw WeatherError.networkError(error)
        } catch {
            throw WeatherError.unknown(error)
        }
    }

    
    func getCurrentWeather(cityName: String) async throws -> Weather {
        // First geocode the city name
        let locations = try await searchLocations(query: cityName)
        
        guard let location = locations.first else {
            throw WeatherError.cityNotFound
        }
        
        return try await getCurrentWeather(for: location)
    }
    
    // MARK: - Forecast
    
    func getForecast(for location: Location) async throws -> Forecast {
        return try await getForecast(
            latitude: location.latitude,
            longitude: location.longitude
        )
    }
    
    func getForecast(latitude: Double, longitude: Double) async throws -> Forecast {
        let endpoint = "\(baseURL)/forecast.json"

            var components = URLComponents(string: endpoint)
            components?.queryItems = [
                URLQueryItem(name: "key", value: apiKey),
                URLQueryItem(name: "q", value: "\(latitude),\(longitude)"),
                URLQueryItem(name: "days", value: "5")
            ]

            guard let url = components?.url else {
                throw WeatherError.invalidURL
            }

            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw WeatherError.invalidResponse
            }

            let forecastResponse = try decoder.decode(WeatherAPIForecastResponse.self, from: data)
            return forecastResponse.toDomain()
    }
    
    // MARK: - Location Search
    
    func searchLocations(query: String) async throws -> [Location] {

        let endpoint = "\(baseURL)/search.json"

        var components = URLComponents(string: endpoint)
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: query)
        ]

        guard let url = components?.url else {
            throw WeatherError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw WeatherError.invalidResponse
        }

        let results = try decoder.decode([WeatherAPISearchResponse].self, from: data)

        return results.map {
            Location(
                name: $0.name,
                country: $0.country,
                latitude: $0.lat,
                longitude: $0.lon
            )
        }
    }


}

// MARK: - Geocoding Response

private struct GeocodingResponse: Decodable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
    
    func toDomain() -> Location {
        Location(
            name: name,
            country: country,
            latitude: lat,
            longitude: lon
        )
    }
}

// MARK: - Weather Error

enum WeatherError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case networkError(URLError)
    case decodingError(DecodingError)
    case cityNotFound
    case rateLimitExceeded
    case invalidAPIKey
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return httpErrorMessage(for: statusCode)
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError:
            return "Failed to decode weather data"
        case .cityNotFound:
            return "City not found. Please check the spelling"
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later"
        case .invalidAPIKey:
            return "Invalid API key. Please check your configuration"
        case .unknown(let error):
            return "Unexpected error: \(error.localizedDescription)"
        }
    }
    
    private func httpErrorMessage(for statusCode: Int) -> String {
        switch statusCode {
        case 401:
            return "Invalid API key"
        case 404:
            return "Location not found"
        case 429:
            return "Too many requests. Please try again later"
        case 500...599:
            return "Server error. Please try again later"
        default:
            return "HTTP error: \(statusCode)"
        }
    }
}

// MARK: - Mock Service for Testing
final class MockWeatherService: WeatherServiceProtocol {
    var shouldFail = false
    var mockWeather: Weather?
    var mockForecast: Forecast?
    var delay: TimeInterval = 0.5
    
    func getCurrentWeather(for location: Location) async throws -> Weather {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        if shouldFail {
            throw WeatherError.networkError(URLError(.notConnectedToInternet))
        }
        
        return mockWeather ?? createMockWeather(for: location)
    }
    
    func getCurrentWeather(latitude: Double, longitude: Double) async throws -> Weather {
        let location = Location(name: "Mock City", country: "MC", latitude: latitude, longitude: longitude)
        return try await getCurrentWeather(for: location)
    }
    
    func getCurrentWeather(cityName: String) async throws -> Weather {
        let location = Location(name: cityName, country: "MC", latitude: 0, longitude: 0)
        return try await getCurrentWeather(for: location)
    }
    
    func getForecast(for location: Location) async throws -> Forecast {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        if shouldFail {
            throw WeatherError.networkError(URLError(.notConnectedToInternet))
        }
        
        return mockForecast ?? createMockForecast(for: location)
    }
    
    func getForecast(latitude: Double, longitude: Double) async throws -> Forecast {
        let location = Location(name: "Mock City", country: "MC", latitude: latitude, longitude: longitude)
        return try await getForecast(for: location)
    }
    
    func searchLocations(query: String) async throws -> [Location] {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        return [
            Location(name: query, country: "US", latitude: 40.7128, longitude: -74.0060),
            Location(name: "\(query) Beach", country: "US", latitude: 34.0522, longitude: -118.2437)
        ]
    }
    
    private func createMockWeather(for location: Location) -> Weather {
        Weather(
            location: location,
            temperature: 22.5,
            feelsLike: 21.0,
            condition: .partlyCloudy,
            conditionDescription: "Partly Cloudy",
            humidity: 65,
            windSpeed: 3.5,
            pressure: 1013.0,
            visibility: 10.0,
            uvIndex: 5,
            cloudCover: 40,
            timestamp: Date()
        )
    }
    
    private func createMockForecast(for location: Location) -> Forecast {
        let hourly = (0..<24).map { hour in
            HourlyForecast(
                time: Date().addingTimeInterval(Double(hour) * 3600),
                temperature: 20.0 + Double.random(in: -5...5),
                feelsLike: 19.0 + Double.random(in: -5...5),
                condition: .partlyCloudy,
                conditionDescription: "Partly Cloudy",
                precipitationChance: Int.random(in: 0...30),
                humidity: 60 + Int.random(in: -10...10),
                windSpeed: 2.0 + Double.random(in: 0...3)
            )
        }
        
        let daily = (0..<5).map { day in
            DailyForecast(
                date: Calendar.current.date(byAdding: .day, value: day, to: Date())!,
                highTemperature: 25.0 + Double.random(in: -3...3),
                lowTemperature: 15.0 + Double.random(in: -3...3),
                condition: .partlyCloudy,
                conditionDescription: "Partly Cloudy",
                precipitationChance: Int.random(in: 0...40),
                humidity: 65,
                windSpeed: 3.0
            )
        }
        
        return Forecast(
            location: location,
            hourlyForecasts: hourly,
            dailyForecasts: daily
        )
    }
}
