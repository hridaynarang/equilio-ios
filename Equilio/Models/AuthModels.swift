import Foundation

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct SignupRequest: Codable {
    let username: String
    let email: String
    let password: String
}

struct AuthResponse: Codable {
    let access_token: String
    let token_type: String
}

struct User: Codable {
    let id: Int
    let username: String
    let email: String
    let created_at: Date
} 