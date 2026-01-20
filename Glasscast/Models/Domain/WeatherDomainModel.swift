//
//  WeatherDomainModel.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import Foundation

// MARK: - Domain Models

struct Weather: Identifiable {
    let id: UUID
    let location: Location
    let temperature: Double
    let feelsLike: Double
    let condition: WeatherCondition
    let conditionDescription: String
    let humidity: Int
    let windSpeed: Double
    let pressure: Double
    let visibility: Double
    let uvIndex: Int?
    let cloudCover: Int
    let timestamp: Date
    
    init(
        id: UUID = UUID(),
        location: Location,
        temperature: Double,
        feelsLike: Double,
        condition: WeatherCondition,
        conditionDescription: String,
        humidity: Int,
        windSpeed: Double,
        pressure: Double,
        visibility: Double,
        uvIndex: Int? = nil,
        cloudCover: Int,
        timestamp: Date
    ) {
        self.id = id
        self.location = location
        self.temperature = temperature
        self.feelsLike = feelsLike
        self.condition = condition
        self.conditionDescription = conditionDescription
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.pressure = pressure
        self.visibility = visibility
        self.uvIndex = uvIndex
        self.cloudCover = cloudCover
        self.timestamp = timestamp
    }
}

struct Location: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let country: String
    let latitude: Double
    let longitude: Double
    let timezone: String?
    var isFavorite: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        country: String,
        latitude: Double,
        longitude: Double,
        timezone: String? = nil,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
        self.isFavorite = isFavorite
    }
}

struct Forecast: Identifiable {
    let id: UUID
    let location: Location
    let hourlyForecasts: [HourlyForecast]
    let dailyForecasts: [DailyForecast]
    
    init(
        id: UUID = UUID(),
        location: Location,
        hourlyForecasts: [HourlyForecast],
        dailyForecasts: [DailyForecast]
    ) {
        self.id = id
        self.location = location
        self.hourlyForecasts = hourlyForecasts
        self.dailyForecasts = dailyForecasts
    }
}

struct HourlyForecast: Identifiable {
    let id: UUID
    let time: Date
    let temperature: Double
    let feelsLike: Double
    let condition: WeatherCondition
    let conditionDescription: String
    let precipitationChance: Int
    let humidity: Int
    let windSpeed: Double
    
    init(
        id: UUID = UUID(),
        time: Date,
        temperature: Double,
        feelsLike: Double,
        condition: WeatherCondition,
        conditionDescription: String,
        precipitationChance: Int,
        humidity: Int,
        windSpeed: Double
    ) {
        self.id = id
        self.time = time
        self.temperature = temperature
        self.feelsLike = feelsLike
        self.condition = condition
        self.conditionDescription = conditionDescription
        self.precipitationChance = precipitationChance
        self.humidity = humidity
        self.windSpeed = windSpeed
    }
}

struct DailyForecast: Identifiable {
    let id: UUID
    let date: Date
    let highTemperature: Double
    let lowTemperature: Double
    let condition: WeatherCondition
    let conditionDescription: String
    let precipitationChance: Int
    let sunrise: Date?
    let sunset: Date?
    let humidity: Int
    let windSpeed: Double
    
    init(
        id: UUID = UUID(),
        date: Date,
        highTemperature: Double,
        lowTemperature: Double,
        condition: WeatherCondition,
        conditionDescription: String,
        precipitationChance: Int,
        sunrise: Date? = nil,
        sunset: Date? = nil,
        humidity: Int,
        windSpeed: Double
    ) {
        self.id = id
        self.date = date
        self.highTemperature = highTemperature
        self.lowTemperature = lowTemperature
        self.condition = condition
        self.conditionDescription = conditionDescription
        self.precipitationChance = precipitationChance
        self.sunrise = sunrise
        self.sunset = sunset
        self.humidity = humidity
        self.windSpeed = windSpeed
    }
}

// MARK: - Weather Condition Enum

enum WeatherCondition: String, Codable {
    case clear
    case partlyCloudy
    case cloudy
    case overcast
    case mist
    case fog
    case lightRain
    case rain
    case heavyRain
    case thunderstorm
    case lightSnow
    case snow
    case heavySnow
    case sleet
    case drizzle
    case unknown
    
    var icon: String {
        switch self {
        case .clear:
            return "sun.max.fill"
        case .partlyCloudy:
            return "cloud.sun.fill"
        case .cloudy, .overcast:
            return "cloud.fill"
        case .mist, .fog:
            return "cloud.fog.fill"
        case .lightRain, .drizzle:
            return "cloud.drizzle.fill"
        case .rain:
            return "cloud.rain.fill"
        case .heavyRain:
            return "cloud.heavyrain.fill"
        case .thunderstorm:
            return "cloud.bolt.rain.fill"
        case .lightSnow:
            return "cloud.snow.fill"
        case .snow, .heavySnow:
            return "snow"
        case .sleet:
            return "cloud.sleet.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .clear:
            return "yellow"
        case .partlyCloudy:
            return "orange"
        case .cloudy, .overcast:
            return "gray"
        case .mist, .fog:
            return "gray"
        case .lightRain, .drizzle, .rain, .heavyRain:
            return "blue"
        case .thunderstorm:
            return "purple"
        case .lightSnow, .snow, .heavySnow, .sleet:
            return "cyan"
        case .unknown:
            return "gray"
        }
    }
}

struct WeatherAPICurrentResponse: Decodable {
    let location: LocationResponse
    let current: CurrentResponse

    struct LocationResponse: Decodable {
        let name: String
        let country: String
        let lat: Double
        let lon: Double
    }

    struct CurrentResponse: Decodable {
        let temp_c: Double
        let feelslike_c: Double
        let humidity: Int
        let wind_kph: Double
        let condition: Condition
    }

    struct Condition: Decodable {
        let text: String
        let code: Int
    }

    func toDomain() -> Weather {
        Weather(
            location: Location(
                name: location.name,
                country: location.country,
                latitude: location.lat,
                longitude: location.lon
            ),
            temperature: current.temp_c,
            feelsLike: current.feelslike_c,
            condition: .partlyCloudy,
            conditionDescription: current.condition.text,
            humidity: current.humidity,
            windSpeed: current.wind_kph / 3.6,
            pressure: 0,
            visibility: 0,
            cloudCover: 0,
            timestamp: Date()
        )
    }
}

struct WeatherAPIForecastResponse: Decodable {
    let location: LocationResponse
    let forecast: ForecastResponse

    struct LocationResponse: Decodable {
        let name: String
        let country: String
        let lat: Double
        let lon: Double
    }

    struct ForecastResponse: Decodable {
        let forecastday: [ForecastDay]
    }

    struct ForecastDay: Decodable {
        let date: String
        let day: Day

        struct Day: Decodable {
            let maxtemp_c: Double
            let mintemp_c: Double
            let condition: Condition
        }

        struct Condition: Decodable {
            let text: String
            let code: Int
        }
    }

    func toDomain() -> Forecast {
        let loc = Location(
            name: location.name,
            country: location.country,
            latitude: location.lat,
            longitude: location.lon
        )

        let daily = forecast.forecastday.map {
            DailyForecast(
                date: weatherAPIDateFormatter.date(from: $0.date) ?? Date(),
                highTemperature: $0.day.maxtemp_c,
                lowTemperature: $0.day.mintemp_c,
                condition: mapWeatherAPICondition($0.day.condition.text),
                conditionDescription: $0.day.condition.text,
                precipitationChance: 0,
                humidity: 0,
                windSpeed: 0
            )
        }

        return Forecast(
            location: loc,
            hourlyForecasts: [],
            dailyForecasts: daily
        )
    }
}

private func mapWeatherAPICondition(_ text: String) -> WeatherCondition {
    let value = text.lowercased()

    switch value {
    case let v where v.contains("sun") || v.contains("clear"):
        return .clear
    case let v where v.contains("partly"):
        return .partlyCloudy
    case let v where v.contains("cloud"):
        return .cloudy
    case let v where v.contains("rain"):
        return .rain
    case let v where v.contains("drizzle"):
        return .drizzle
    case let v where v.contains("thunder"):
        return .thunderstorm
    case let v where v.contains("snow"):
        return .snow
    case let v where v.contains("fog") || v.contains("mist"):
        return .fog
    default:
        return .unknown
    }
}

private let weatherAPIDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    df.locale = Locale(identifier: "en_US_POSIX")
    return df
}()

struct WeatherAPISearchResponse: Decodable {
    let name: String
    let country: String
    let lat: Double
    let lon: Double
}
