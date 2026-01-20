//
//  SettingsViewModel.swift
//  Glasscast
//
//  Created by selegic mac 01 on 20/01/26.
//

import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {

    @AppStorage("temperature_unit")
    var temperatureUnit: TemperatureUnit = .celsius
    private let authService: AuthenticationServiceProtocol

    init(authService: AuthenticationServiceProtocol) {
        self.authService = authService
    }

    func signOut() async {
        do {
            try await authService.signOut()
        } catch {
            print("❌ Sign out failed:", error.localizedDescription)
        }
    }
}
