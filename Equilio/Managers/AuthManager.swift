import Foundation
import SwiftUI

@MainActor
class AuthManager: ObservableObject {
    @AppStorage("jwt") private var jwt: String = ""
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    private let authService: AuthService
    
    init() {
        self.authService = AuthService()
        self.isAuthenticated = !jwt.isEmpty
    }
    
    func login(email: String, password: String) async throws {
        do {
            let response = try await authService.login(email: email, password: password)
            jwt = response.access_token
            currentUser = response.user
            isAuthenticated = true
        } catch {
            throw error
        }
    }
    
    func signup(username: String, email: String, password: String) async throws {
        do {
            let response = try await authService.signup(username: username, email: email, password: password)
            jwt = response.access_token
            currentUser = response.user
            isAuthenticated = true
        } catch {
            throw error
        }
    }
    
    func logout() {
        jwt = ""
        currentUser = nil
        isAuthenticated = false
    }
    
    func getAuthHeader() -> [String: String] {
        return ["Authorization": "Bearer \(jwt)"]
    }
    
    // MARK: - Token Validation
    
    func isTokenValid() -> Bool {
        guard !jwt.isEmpty else { return false }
        
        // Check if token is expired
        if let expirationDate = getTokenExpirationDate() {
            return expirationDate > Date()
        }
        
        return false
    }
    
    private func getTokenExpirationDate() -> Date? {
        let components = jwt.components(separatedBy: ".")
        guard components.count == 3,
              let payloadData = Data(base64Encoded: components[1].padding(toLength: ((components[1].count + 3) / 4) * 4, withPad: "=", startingAt: 0)),
              let payload = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let exp = payload["exp"] as? TimeInterval else {
            return nil
        }
        
        return Date(timeIntervalSince1970: exp)
    }
    
    // MARK: - Token Refresh
    
    func refreshTokenIfNeeded() async throws {
        guard isTokenValid() else {
            // Token is expired or invalid, log out user
            logout()
            throw AuthError.invalidToken
        }
    }
}

// MARK: - Auth Error

enum AuthError: LocalizedError {
    case invalidToken
    case unauthorized
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidToken:
            return "Your session has expired. Please log in again."
        case .unauthorized:
            return "You are not authorized to perform this action."
        case .networkError:
            return "A network error occurred. Please check your connection."
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
} 