import Foundation

// Use User and Group from Models.swift

struct FriendRequest: Codable, Identifiable {
    let id: Int
    let sender: User
    let receiver: User
    let status: String
    let created_at: String
}

struct Message: Codable, Identifiable {
    let id: Int
    let sender: User
    let content: String
    let created_at: String
}

struct FriendsResponse: Codable {
    let friends: [User]
    let groups: [Group]
    let pending_requests: [FriendRequest]
    let recent_messages: [Message]
} 