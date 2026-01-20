//
//  Environment.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import Foundation
import SwiftUI

enum AppEnvironment {
    
    // MARK: - Keys
    private enum Keys {
        static let supabaseURL = "SUPABASE_URL"
        static let supabaseAnonKey = "SUPABASE_ANON_KEY"
        static let weatherAPIKey = "WEATHER_API_KEY"
    }
    
    // MARK: - Supabase Configuration
    static var supabaseURL: String {
        guard let url = getEnvironmentVariable(Keys.supabaseURL) else {
            fatalError("❌ SUPABASE_URL not found in environment variables")
        }
        return url
    }
    
    static var supabaseAnonKey: String {
        guard let key = getEnvironmentVariable(Keys.supabaseAnonKey) else {
            fatalError("❌ SUPABASE_ANON_KEY not found in environment variables")
        }
        return key
    }
    
    // MARK: - Weather API Configuration
    static var weatherAPIKey: String {
        guard let key = getEnvironmentVariable(Keys.weatherAPIKey) else {
            fatalError("❌ WEATHER_API_KEY not found in environment variables")
        }
        return key
    }
    
    // MARK: - Helper Method
    private static func getEnvironmentVariable(_ key: String) -> String? {
        // First check ProcessInfo (works for Xcode schemes)
        if let value = ProcessInfo.processInfo.environment[key], !value.isEmpty {
            return value
        }
        
        // Fallback to Info.plist
        if let value = Bundle.main.object(forInfoDictionaryKey: key) as? String, !value.isEmpty {
            return value
        }
        
        return nil
    }
    
    // MARK: - Debug Helper
    static func validateConfiguration() {
        #if DEBUG
        print("🔐 Environment Configuration:")
        print("  Supabase URL: \(supabaseURL)")
        print("  Supabase Key: \(supabaseAnonKey.prefix(20))...")
        print("  Weather API Key: \(weatherAPIKey.prefix(10))...")
        #endif
    }
}

extension View {
    /// Applies iOS 18+ liquid glass effect to any view
    /// Creates a frosted glass appearance with subtle blur and shine
    func glassEffect() -> some View {
        self
            .background(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.3),
                                .white.opacity(0.1),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
