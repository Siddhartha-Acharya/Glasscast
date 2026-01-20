//
//  SettingsContentView.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import SwiftUI

struct SettingsContentView: View {
    @EnvironmentObject var appSettings: AppSettings
    @StateObject private var vm = SettingsViewModel(
        authService: DIContainer.shared.authenticationService
    )
    let authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            // Same background as Home / Favorites
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            GlassEffectContainer {
                VStack(spacing: 24) {

                    // MARK: - Temperature Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Temperature Unit")
                            .font(.headline)

                        Picker("Temperature Unit", selection: $appSettings.temperatureUnit) {
                            Text("Celsius").tag(TemperatureUnit.celsius)
                            Text("Fahrenheit").tag(TemperatureUnit.fahrenheit)
                        }
                        .pickerStyle(.segmented)

                    }
                    .padding()
                    .glassEffect()
                    .clipShape(RoundedRectangle(cornerRadius: 22))

                    // MARK: - Sign Out
                    Button {
                        Task {
                            await authViewModel.signOut()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .glassEffect()
                    .clipShape(RoundedRectangle(cornerRadius: 22))

                    Spacer()
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
