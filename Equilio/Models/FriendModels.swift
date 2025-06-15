import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let username: String
    let email: String
    let created_at: String
}

struct Group: Codable, Identifiable {
    let id: Int
    let name: String
    let created_by: Int
    let created_at: String
    let members: [User]
}

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