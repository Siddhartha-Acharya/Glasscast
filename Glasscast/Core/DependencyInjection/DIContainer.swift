//
//  DIContainer.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import Foundation
import Supabase
import Combine
import SwiftUI

@MainActor
final class DIContainer: ObservableObject {
    
    // MARK: - Singleton
    static let shared = DIContainer()
    
    // MARK: - Core Dependencies
     let supabaseClient: SupabaseClient
    
    // MARK: - Services (Lazy-loaded singletons)
    private(set) lazy var authenticationService: AuthenticationServiceProtocol = {
        AuthenticationService(supabaseClient: supabaseClient)
    }()
    
    // Add more services as needed
    // private(set) lazy var weatherService: WeatherServiceProtocol = { ... }()
    // private(set) lazy var locationService: LocationServiceProtocol = { ... }()
    // private(set) lazy var favoriteCitiesService: FavoriteCitiesServiceProtocol = { ... }()
    private(set) lazy var weatherService: WeatherServiceProtocol = {
            WeatherService(apiKey: AppEnvironment.weatherAPIKey)
        }()
        // Location Service
        private(set) lazy var locationService: LocationServiceProtocol = {
            LocationService()
        }()
    
    // MARK: - Initialization
    private init() {
        // Initialize Supabase client with environment variables
        self.supabaseClient = SupabaseClient(
            supabaseURL: URL(string: AppEnvironment.supabaseURL)!,
            supabaseKey: AppEnvironment.supabaseAnonKey
        )
        
        #if DEBUG
        AppEnvironment.validateConfiguration()
        print("✅ DIContainer initialized with Supabase client")
        #endif
    }
    
    // MARK: - ViewModel Factories
    
    func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(authService: authenticationService)
    }
        
        func makeHomeViewModel() -> HomeViewModel {
            HomeViewModel(
                weatherService: weatherService,
                locationService: locationService
            )
        }
    
    // Add more ViewModel factories as needed
    // func makeHomeViewModel() -> HomeViewModel { ... }
    // func makeFavoriteCitiesViewModel() -> FavoriteCitiesViewModel { ... }
}

// MARK: - Environment Key for SwiftUI
struct DIContainerKey: EnvironmentKey {
    static let defaultValue: DIContainer = .shared
}

extension EnvironmentValues {
    var diContainer: DIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}
