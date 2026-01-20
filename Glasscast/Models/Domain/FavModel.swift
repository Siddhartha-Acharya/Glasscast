//
//  FavModel.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import Foundation

struct FavoriteCity: Identifiable, Decodable {
    let id: UUID
    let city_name: String
    let lat: Double
    let lon: Double
}

struct FavoriteCityInsert: Encodable {
    let user_id: UUID
    let city_name: String
    let lat: Double
    let lon: Double
}
