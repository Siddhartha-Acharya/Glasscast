//
//  ForecastSection.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import SwiftUI

struct ForecastSection: View {
    let forecast: DailyForecast
    @EnvironmentObject var appSettings: AppSettings
    var displayHighTemperature: String {
        switch appSettings.temperatureUnit {
        case .celsius:
            return "\(Int(forecast.highTemperature))°C"
        case .fahrenheit:
            let f = (forecast.highTemperature * 9/5) + 32
            return "\(Int(f))°F"
        }
    }
    
    var displayLowTemperature: String {
        switch appSettings.temperatureUnit {
        case .celsius:
            return "\(Int(forecast.lowTemperature))°C"
        case .fahrenheit:
            let f = (forecast.lowTemperature * 9/5) + 32
            return "\(Int(f))°F"
        }
    }

    var body: some View {
        GlassContainer {
            VStack(spacing: 8) {
                Text(forecast.date, format: .dateTime.weekday())
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)

                Image(systemName: forecast.condition.icon)
                    .font(.title2)

                Text("\(displayHighTemperature)")
                    .font(.headline)

                Text("\(displayLowTemperature)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 90)
        }
    }
}
