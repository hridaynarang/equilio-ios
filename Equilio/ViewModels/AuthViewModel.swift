import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var isgup = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authManager: AuthManager
    
    init(authManager: AuthManager = AuthManager()) {
        self.authManager = authManager
    }
    
    var isAuthenticated: Bool {
        authManager.isAuthenticated
    }
    
    func authenticate() async {
        isLoading = true
        errorMessage = nil
        
        do {
            if isSignup {
                try await authManager.signup(username: username, email: email, password: password)
            } else {
                try await authManager.login(username: email, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func validateInput() -> Bool {
        if isSignup {
            return !username.isEmpty && !email.isEmpty && !password.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    func logout() {
        authManager.logout()
    }
} 