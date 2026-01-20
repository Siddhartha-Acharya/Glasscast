//
//  FavoriteWeatherCard.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import SwiftUI

struct FavoriteCityGlassCard: View {
    let weather: Weather
    @EnvironmentObject var appSettings: AppSettings
    var displayHighTemperature: String {
        switch appSettings.temperatureUnit {
        case .celsius:
            return "\(Int(weather.temperature))°C"
        case .fahrenheit:
            let f = (weather.temperature * 9/5) + 32
            return "\(Int(f))°F"
        }
    }

    var body: some View {
        HStack(spacing: 16) {

            // LEFT: City + condition
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(weather.location.name)
                        .font(.headline)
                        .foregroundColor(.black)
                }

                Text(weather.conditionDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .foregroundColor(.gray)
            }

            Spacer()

            // RIGHT: Temp + Icon
            HStack(spacing: 12) {
                Text("\(displayHighTemperature)")
                    .font(.title2.weight(.semibold))

                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 44, height: 44)

                    Image(systemName: weather.condition.icon)
                        .font(.title3)
                        .symbolRenderingMode(.multicolor)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(.white.opacity(0.15))
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
    }
}
