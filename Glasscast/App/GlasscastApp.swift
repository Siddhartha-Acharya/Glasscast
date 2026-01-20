//
//  GlasscastApp.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import SwiftUI

@main
struct GlasscastApp: App {
    @StateObject private var container = DIContainer.shared
    @StateObject private var appSettings = AppSettings()
    
        var body: some Scene {
            WindowGroup {
                RootView()
                    .environmentObject(container)
                    .environmentObject(appSettings)
            }
        }
}
