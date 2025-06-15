import Foundation

enum FriendError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
}

class FriendService {
    private let baseURL = "http://localhost:8000"
    private let token: String
    
    init(token: String) {
        self.token = token
    }
    
    func getFriends() async throws -> FriendsResponse {
        guard let url = URL(string: "\(baseURL)/friends") else {
            throw FriendError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw FriendError.invalidResponse
            }
            
            do {
                let friendsResponse = try JSONDecoder().decode(FriendsResponse.self, from: data)
                return friendsResponse
            } catch {
                throw FriendError.decodingError(error)
            }
        } catch {
            throw FriendError.networkError(error)
        }
    }
    
    func sendFriendRequest(username: String) async throws {
        guard let url = URL(string: "\(baseURL)/friends/request") else {
            throw FriendError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["username": username]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw FriendError.invalidResponse
        }
    }
    
    func createGroup(name: String) async throws -> Group {
        guard let url = URL(string: "\(baseURL)/groups") else {
            throw FriendError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["name": name]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw FriendError.invalidResponse
        }
        
        do {
            let group = try JSONDecoder().decode(Group.self, from: data)
            return group
        } catch {
            throw FriendError.decodingError(error)
        }
    }
} 