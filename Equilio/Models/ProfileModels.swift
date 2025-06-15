import Foundation

struct UserProfile: Codable {
    let id: Int
    let username: String
    let email: String
    let created_at: String
    let stats: UserStats
    let recent_receipts: [Receipt]
}

struct UserStats: Codable {
    let total_receipts: Int
    let total_amount: Double
    let active_receipts: Int
    let settled_receipts: Int
} 