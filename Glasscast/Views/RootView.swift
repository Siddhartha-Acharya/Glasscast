//
//  RootView.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import SwiftUI

struct RootView: View {

    @StateObject private var authViewModel: AuthViewModel
    
    init(container: DIContainer = .shared) {
        _authViewModel = StateObject(
            wrappedValue: container.makeAuthViewModel()
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if authViewModel.isAuthenticated {
                    MainTabView(authViewModel: authViewModel)
                } else {
                    AuthView(viewModel: authViewModel)
                }
            }
            .onAppear {
                authViewModel.restoreSession()
            }
            .animation(.easeInOut, value: authViewModel.isAuthenticated)
        }
    }
}
