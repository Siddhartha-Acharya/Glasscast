//
//  OpenWeatherMap.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import Foundation

// MARK: - OpenWeatherMap API Response Models

// Current Weather Response
struct OpenWeatherCurrentResponse: Decodable {
    let coord: Coordinates
    let weather: [WeatherInfo]
    let main: MainWeatherData
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: TimeInterval
    let sys: Sys
    let timezone: Int
    let name: String
    
    struct Coordinates: Decodable {
        let lon: Double
        let lat: Double
    }
    
    struct WeatherInfo: Decodable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    struct MainWeatherData: Decodable {
        let temp: Double
        let feels_like: Double
        let temp_min: Double
        let temp_max: Double
        let pressure: Double
        let humidity: Int
    }
    
    struct Wind: Decodable {
        let speed: Double
        let deg: Int?
    }
    
    struct Clouds: Decodable {
        let all: Int
    }
    
    struct Sys: Decodable {
        let country: String
        let sunrise: TimeInterval?
        let sunset: TimeInterval?
    }
    
    // MARK: - Mapping to Domain Model
    
    func toDomain(location: Location? = nil) -> Weather {
        let loc = location ?? Location(
            name: name,
            country: sys.country,
            latitude: coord.lat,
            longitude: coord.lon
        )
        
        return Weather(
            location: loc,
            temperature: main.temp,
            feelsLike: main.feels_like,
            condition: mapCondition(weatherId: weather.first?.id ?? 0),
            conditionDescription: weather.first?.description.capitalized ?? "Unknown",
            humidity: main.humidity,
            windSpeed: wind.speed,
            pressure: main.pressure,
            visibility: Double(visibility) / 1000.0, // Convert to km
            uvIndex: nil,
            cloudCover: clouds.all,
            timestamp: Date(timeIntervalSince1970: dt)
        )
    }
}

// 5-Day Forecast Response
struct OpenWeatherForecastResponse: Decodable {
    let list: [ForecastItem]
    let city: City
    
    struct ForecastItem: Decodable {
        let dt: TimeInterval
        let main: MainData
        let weather: [WeatherInfo]
        let clouds: Clouds
        let wind: Wind
        let pop: Double // Probability of precipitation
        let dt_txt: String
        
        struct MainData: Decodable {
            let temp: Double
            let feels_like: Double
            let temp_min: Double
            let temp_max: Double
            let pressure: Double
            let humidity: Int
        }
        
        struct WeatherInfo: Decodable {
            let id: Int
            let main: String
            let description: String
        }
        
        struct Clouds: Decodable {
            let all: Int
        }
        
        struct Wind: Decodable {
            let speed: Double
        }
    }
    
    struct City: Decodable {
        let name: String
        let country: String
        let timezone: Int
        let sunrise: TimeInterval
        let sunset: TimeInterval
        let coord: Coordinates
        
        struct Coordinates: Decodable {
            let lat: Double
            let lon: Double
        }
    }
    
    // MARK: - Mapping to Domain Models
    
    func toDomain(location: Location? = nil) -> Forecast {
        let loc = location ?? Location(
            name: city.name,
            country: city.country,
            latitude: city.coord.lat,
            longitude: city.coord.lon
        )
        
        // Map hourly forecasts (next 24-48 hours)
        let hourlyForecasts = list.prefix(16).map { item -> HourlyForecast in
            HourlyForecast(
                time: Date(timeIntervalSince1970: item.dt),
                temperature: item.main.temp,
                feelsLike: item.main.feels_like,
                condition: mapCondition(weatherId: item.weather.first?.id ?? 0),
                conditionDescription: item.weather.first?.description.capitalized ?? "Unknown",
                precipitationChance: Int(item.pop * 100),
                humidity: item.main.humidity,
                windSpeed: item.wind.speed
            )
        }
        
        // Map daily forecasts (group by day)
        let dailyForecasts = groupByDay(items: list, cityTimezone: city.timezone)
        
        return Forecast(
            location: loc,
            hourlyForecasts: Array(hourlyForecasts),
            dailyForecasts: dailyForecasts
        )
    }
    
    private func groupByDay(items: [ForecastItem], cityTimezone: Int) -> [DailyForecast] {
        let calendar = Calendar.current
        
        // Group items by day
        let grouped = Dictionary(grouping: items) { item -> Date in
            let date = Date(timeIntervalSince1970: item.dt)
            return calendar.startOfDay(for: date)
        }
        
        // Convert to daily forecasts
        return grouped.sorted { $0.key < $1.key }.prefix(5).map { (date, items) in
            let temps = items.map { $0.main.temp }
            let maxTemp = temps.max() ?? 0
            let minTemp = temps.min() ?? 0
            
            // Use midday item for condition (around 12:00)
            let middayItem = items.sorted { abs($0.dt - date.timeIntervalSince1970 - 43200) < abs($1.dt - date.timeIntervalSince1970 - 43200) }.first ?? items.first!
            
            let avgPrecip = items.map { $0.pop }.reduce(0, +) / Double(items.count)
            let avgHumidity = items.map { $0.main.humidity }.reduce(0, +) / items.count
            let avgWind = items.map { $0.wind.speed }.reduce(0, +) / Double(items.count)
            
            return DailyForecast(
                date: date,
                highTemperature: maxTemp,
                lowTemperature: minTemp,
                condition: mapCondition(weatherId: middayItem.weather.first?.id ?? 0),
                conditionDescription: middayItem.weather.first?.description.capitalized ?? "Unknown",
                precipitationChance: Int(avgPrecip * 100),
                sunrise: date == calendar.startOfDay(for: Date()) ? Date(timeIntervalSince1970: city.sunrise) : nil,
                sunset: date == calendar.startOfDay(for: Date()) ? Date(timeIntervalSince1970: city.sunset) : nil,
                humidity: avgHumidity,
                windSpeed: avgWind
            )
        }
    }
}

// MARK: - Weather Condition Mapping

private func mapCondition(weatherId: Int) -> WeatherCondition {
    switch weatherId {
    case 800:
        return .clear
    case 801:
        return .partlyCloudy
    case 802:
        return .cloudy
    case 803, 804:
        return .overcast
    case 701, 741:
        return .fog
    case 711, 721, 731, 751, 761, 762:
        return .mist
    case 300...321:
        return .drizzle
    case 500:
        return .lightRain
    case 501, 502, 503, 504:
        return .rain
    case 511, 520, 521, 522, 531:
        return .heavyRain
    case 200...232:
        return .thunderstorm
    case 600:
        return .lightSnow
    case 601:
        return .snow
    case 602, 611, 612, 613, 615, 616, 620, 621, 622:
        return .heavySnow
    default:
        return .unknown
    }
}
