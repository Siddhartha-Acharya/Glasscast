//
//  AppSettings.swift
//  Glasscast
//
//  Created by selegic mac 01 on 20/01/26.
//

import Foundation
import Combine

@MainActor
final class AppSettings: ObservableObject {

    @Published var temperatureUnit: TemperatureUnit = .celsius {
        didSet {
            UserDefaults.standard.set(
                temperatureUnit.rawValue,
                forKey: "temperature_unit"
            )
        }
    }

    init() {
        if let saved = UserDefaults.standard.string(forKey: "temperature_unit"),
           let unit = TemperatureUnit(rawValue: saved) {
            temperatureUnit = unit
        }
    }
}

