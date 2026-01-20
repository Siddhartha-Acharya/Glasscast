//
//  AppAuthState.swift
//  Glasscast
//
//  Created by selegic mac 01 on 20/01/26.
//

import Foundation
import Combine

@MainActor
final class AppAuthState: ObservableObject {
    @Published var isAuthenticated: Bool = false
}
