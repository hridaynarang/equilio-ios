import Foundation

enum ProfileError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
}

class ProfileService {
    private let baseURL = "http://localhost:8000"
    private let token: String
    
    init(token: String) {
        self.token = token
    }
    
    func getProfile() async throws -> UserProfile {
        guard let url = URL(string: "\(baseURL)/users/me") else {
            throw ProfileError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw ProfileError.invalidResponse
            }
            
            do {
                let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                return profile
            } catch {
                throw ProfileError.decodingError(error)
            }
        } catch {
            throw ProfileError.networkError(error)
        }
    }
    
    func updateProfile(username: String, email: String) async throws -> UserProfile {
        guard let url = URL(string: "\(baseURL)/users/me") else {
            throw ProfileError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["username": username, "email": email]
        request.httpBody = try JSONEncoder().encode(body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw ProfileError.invalidResponse
            }
            
            do {
                let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                return profile
            } catch {
                throw ProfileError.decodingError(error)
            }
        } catch {
            throw ProfileError.networkError(error)
        }
    }
} 