import Foundation

enum AuthError: Error {
    case invalidURL
    case invalidResponse
    case networkError
    case decodingError
    case unauthorized
}

class AuthService {
    private let baseURL = "http://localhost:8000"
    private let authManager: AuthManager
    
    init(authManager: AuthManager = AuthManager()) {
        self.authManager = authManager
    }
    
    func login(email: String, password: String) async throws -> AuthResponse {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginRequest = LoginRequest(email: email, password: password)
        request.httpBody = try JSONEncoder().encode(loginRequest)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                if httpResponse.statusCode == 401 {
                    throw AuthError.unauthorized
                }
                throw AuthError.networkError
            }
            
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                return authResponse
            } catch {
                throw AuthError.decodingError
            }
        } catch {
            throw AuthError.networkError
        }
    }
    
    func signup(username: String, email: String, password: String) async throws -> AuthResponse {
        guard let url = URL(string: "\(baseURL)/auth/signup") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let signupRequest = SignupRequest(username: username, email: email, password: password)
        request.httpBody = try JSONEncoder().encode(signupRequest)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            guard httpResponse.statusCode == 201 else {
                if httpResponse.statusCode == 401 {
                    throw AuthError.unauthorized
                }
                throw AuthError.networkError
            }
            
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                return authResponse
            } catch {
                throw AuthError.decodingError
            }
        } catch {
            throw AuthError.networkError
        }
    }
    
    func getAuthHeader() -> [String: String] {
        return authManager.getAuthHeader()
    }
} 