//
//  AuthenticationServiceProtocol.swift
//  Glasscast
//
//  Created by selegic mac 01 on 19/01/26.
//

import Foundation
import Supabase

// MARK: - Protocol
protocol AuthenticationServiceProtocol {
    func signUp(email: String, password: String) async throws -> User
    func signIn(email: String, password: String) async throws -> User
    func signOut() async throws
    func getCurrentUser() async throws -> User?
    func refreshSession() async throws
}

// MARK: - Implementation
final class AuthenticationService: AuthenticationServiceProtocol {
    
    private let supabaseClient: SupabaseClient
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    func signUp(email: String, password: String) async throws -> User {
        do {
            let response = try await supabaseClient.auth.signUp(
                email: email,
                password: password
            )
        
            let user = response.user
            
            return User(
                id: user.id,
                email: user.email ?? email,
                createdAt: user.createdAt
            )
        } catch let error as AuthError {
            throw error
        } catch {
            throw mapSupabaseError(error)
        }
    }
    
    func signIn(email: String, password: String) async throws -> User {
        do {
            let session = try await supabaseClient.auth.signIn(
                email: email,
                password: password
            )
            
            return User(
                id: session.user.id,
                email: session.user.email ?? email,
                createdAt: session.user.createdAt
            )
        } catch {
            throw mapSupabaseError(error)
        }
    }
    
    func signOut() async throws {
        do {
            try await supabaseClient.auth.signOut()
        } catch {
            throw AuthError.unknown("Sign out failed")
        }
    }
    
    func getCurrentUser() async throws -> User? {
        do {
            let session = try await supabaseClient.auth.session
            
            return User(
                id: session.user.id,
                email: session.user.email ?? "",
                createdAt: session.user.createdAt
            )
        } catch {
            // No session means not authenticated
            return nil
        }
    }
    
    func refreshSession() async throws {
        do {
            _ = try await supabaseClient.auth.refreshSession()
        } catch {
            throw AuthError.unknown("Session refresh failed")
        }
    }
    
    // MARK: - Error Mapping
    
    private func mapSupabaseError(_ error: Error) -> AuthError {
        let errorMessage = error.localizedDescription.lowercased()
        
        if errorMessage.contains("invalid") || errorMessage.contains("credentials") {
            return .invalidCredentials
        } else if errorMessage.contains("already") || errorMessage.contains("exists") {
            return .userAlreadyExists
        } else if errorMessage.contains("weak") || errorMessage.contains("password") {
            return .weakPassword
        } else if errorMessage.contains("network") || errorMessage.contains("connection") {
            return .networkError
        } else {
            return .unknown(error.localizedDescription)
        }
    }
}
