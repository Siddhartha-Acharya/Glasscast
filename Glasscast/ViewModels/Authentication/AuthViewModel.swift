//
//  AuthViewModel.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import Foundation
import Supabase
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    
    // MARK: - Dependencies
    private let authService: AuthenticationServiceProtocol
    
    // MARK: - Initialization
    init(authService: AuthenticationServiceProtocol) {
        self.authService = authService
        Task {
            await checkAuthenticationStatus()
        }
    }
    
    let supabase = SupabaseClient(
        supabaseURL: URL(string: AppEnvironment.supabaseURL)!,
        supabaseKey: AppEnvironment.supabaseAnonKey
    )
    
    // MARK: - Authentication Methods
    
    /// Sign up a new user with email and password
    func signUp() async {
        guard validateSignUpInput() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.signUp(email: email, password: password)
            self.currentUser = user
            self.isAuthenticated = true
            clearFields()
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// Sign in an existing user with email and password
    func signIn() async {
        guard validateSignInInput() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.signIn(email: email, password: password)
            self.currentUser = user
            self.isAuthenticated = true
            clearFields()
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// Sign out the current user
    func signOut() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signOut()
            self.currentUser = nil
            self.isAuthenticated = false
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// Check if user is already authenticated
    func checkAuthenticationStatus() async {
        do {
            if let user = try await authService.getCurrentUser() {
                self.currentUser = user
                self.isAuthenticated = true
            } else {
                self.isAuthenticated = false
            }
        } catch {
            self.isAuthenticated = false
        }
    }
    
    // MARK: - Validation
    
    private func validateSignUpInput() -> Bool {
        errorMessage = nil
        
        guard !email.isEmpty else {
            errorMessage = "Email cannot be empty"
            return false
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return false
        }
        
        guard !password.isEmpty else {
            errorMessage = "Password cannot be empty"
            return false
        }
        
        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            return false
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return false
        }
        
        return true
    }
    
    private func validateSignInInput() -> Bool {
        errorMessage = nil
        
        guard !email.isEmpty else {
            errorMessage = "Email cannot be empty"
            return false
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return false
        }
        
        guard !password.isEmpty else {
            errorMessage = "Password cannot be empty"
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Helper Methods
    
    private func handleError(_ error: Error) {
        if let authError = error as? AuthError {
            errorMessage = authError.localizedDescription
        } else {
            errorMessage = "An unexpected error occurred. Please try again."
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    private func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
    }
    
    func signOut(authState: AppAuthState) async {
        do {
            try await supabase.auth.signOut()
            authState.isAuthenticated = false
        } catch {
            print("Sign out error:", error)
        }
    }
    
    func restoreSession() {
           isAuthenticated = supabase.auth.currentSession != nil
       }
}

// MARK: - Custom Error Types
enum AuthError: LocalizedError {
    case invalidCredentials
    case userAlreadyExists
    case weakPassword
    case networkError
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .userAlreadyExists:
            return "An account with this email already exists"
        case .weakPassword:
            return "Password is too weak. Use at least 8 characters with numbers and symbols"
        case .networkError:
            return "Network error. Please check your connection"
        case .unknown(let message):
            return message
        }
    }
}
