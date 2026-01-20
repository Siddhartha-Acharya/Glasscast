//
//  AuthView.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel: AuthViewModel
    @State private var isSignUpMode: Bool = false
    
    init(viewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                Spacer()
                
                // Logo and title
                logoSection
                
                Spacer()
                
                // Auth form in glass container
                authFormContainer
                
                Spacer()
                
                // Toggle between sign in/up
                toggleModeButton
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            // Loading overlay
            if viewModel.isLoading {
                loadingOverlay
            }
        }
    }
    
    // MARK: - Logo Section
    
    private var logoSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Glasscast")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Minimal Weather Experience")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - Auth Form Container
    
    private var authFormContainer: some View {
        VStack(spacing: 20) {
            // Title
            Text(isSignUpMode ? "Create Account" : "Welcome Back")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            // Error message
            if let errorMessage = viewModel.errorMessage {
                errorMessageView(errorMessage)
            }
            
            // Email field
            AuthTextField(
                icon: "envelope.fill",
                placeholder: "Email",
                text: $viewModel.email,
                keyboardType: .emailAddress
            )
            
            // Password field
            AuthSecureField(
                icon: "lock.fill",
                placeholder: "Password",
                text: $viewModel.password
            )
            
            // Confirm password (sign up only)
            if isSignUpMode {
                AuthSecureField(
                    icon: "lock.fill",
                    placeholder: "Confirm Password",
                    text: $viewModel.confirmPassword
                )
            }
            
            // Submit button
            submitButton
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .glassEffect()
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        Button {
            Task {
                if isSignUpMode {
                    await viewModel.signUp()
                } else {
                    await viewModel.signIn()
                }
            }
        } label: {
            Text(isSignUpMode ? "Sign Up" : "Sign In")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(viewModel.isLoading)
        .opacity(viewModel.isLoading ? 0.6 : 1.0)
    }
    
    // MARK: - Toggle Mode Button
    
    private var toggleModeButton: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                isSignUpMode.toggle()
                viewModel.clearError()
            }
        } label: {
            HStack(spacing: 4) {
                Text(isSignUpMode ? "Already have an account?" : "Don't have an account?")
                    .foregroundColor(.white.opacity(0.8))
                
                Text(isSignUpMode ? "Sign In" : "Sign Up")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .font(.subheadline)
        }
    }
    
    // MARK: - Error Message View
    
    private func errorMessageView(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption)
            
            Text(message)
                .font(.caption)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .foregroundColor(.red)
        .padding(12)
        .background(.red.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Loading Overlay
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Loading...")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .glassEffect()
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

// MARK: - Custom Text Field Components

struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .foregroundColor(.white)
                .tint(.white)
        }
        .padding(16)
        .background(.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct AuthSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @State private var isSecure: Bool = true
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 20)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .autocapitalization(.none)
            .foregroundColor(.white)
            .tint(.white)
            
            Button {
                isSecure.toggle()
            } label: {
                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(16)
        .background(.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview
#Preview {
    AuthView(viewModel: AuthViewModel(
        authService: MockAuthenticationService()
    ))
}

// Mock service for preview
class MockAuthenticationService: AuthenticationServiceProtocol {
    func signUp(email: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return User(id: UUID(), email: email, createdAt: Date())
    }
    
    func signIn(email: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return User(id: UUID(), email: email, createdAt: Date())
    }
    
    func signOut() async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    func getCurrentUser() async throws -> User? {
        return nil
    }
    
    func refreshSession() async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }
}
