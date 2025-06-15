import Foundation

// MARK: - User
struct User: Identifiable, Codable {
    let id: Int
    let username: String
    let email: String
    let created_at: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: created_at) {
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
        return created_at
    }
}

// MARK: - Group
struct Group: Identifiable, Codable {
    let id: Int
    let name: String
    let created_by: Int
    let created_at: String
    let members: [User]
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: created_at) {
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
        return created_at
    }
}

// MARK: - Receipt
struct Receipt: Identifiable, Codable {
    let id: Int
    let description: String
    let amount: Double
    let created_by: Int
    let group_id: Int?
    let created_at: String
    let status: String
    let image_url: String?
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: created_at) {
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
        return created_at
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - User Stats
struct UserStats: Codable {
    let total_receipts: Int
    let total_amount: Double
    let active_receipts: Int
    let settled_receipts: Int
    
    var formattedTotalAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: total_amount)) ?? "$0.00"
    }
}

// MARK: - User Profile
struct UserProfile: Codable {
    let user: User
    let stats: UserStats
    let recent_receipts: [Receipt]
}

// MARK: - Group Stats
struct GroupStats: Codable {
    let total_receipts: Int
    let total_amount: Double
    let active_receipts: Int
    let settled_receipts: Int
    let member_balances: [Int: Double] // user_id: balance
    
    var formattedTotalAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: total_amount)) ?? "$0.00"
    }
}

// MARK: - Group Detail
struct GroupDetail: Codable {
    let group: Group
    let stats: GroupStats
    let recent_receipts: [Receipt]
} 