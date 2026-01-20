//
//  WeatherCard.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import SwiftUI

struct WeatherCard: View {
    @EnvironmentObject var appSettings: AppSettings
    let weather: Weather
    var displayTemperature: String {
            switch appSettings.temperatureUnit {
            case .celsius:
                return "\(Int(weather.temperature))°C"
            case .fahrenheit:
                let f = (weather.temperature * 9/5) + 32
                return "\(Int(f))°F"
            }
        }

    var body: some View {
       
            VStack(spacing: 16) {
                Image(systemName: weather.condition.icon)
                    .font(.system(size: 64))
                    .symbolRenderingMode(.multicolor)
                
                

                Text("\(displayTemperature)")
                    .font(.system(size: 76, weight: .thin))

                Text(weather.conditionDescription)
                    .foregroundStyle(.secondary)

                HStack(spacing: 16) {
                    Text("H \(Int(weather.temperature + 3))°")
                    Text("L \(Int(weather.temperature - 3))°")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        
    }
}

struct GlassContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GlassEffectContainer {
            content
                .padding(24)
                .glassEffect()
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
    }
}
