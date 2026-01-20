//
//  AuthModel.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    let email: String
    let createdAt: Date
    
    var temperatureUnit: TemperatureUnit = .celsius
    var favoriteCityIds: [UUID] = []
}

enum TemperatureUnit: String, Codable, CaseIterable {
    case celsius
    case fahrenheit

    var symbol: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
}
