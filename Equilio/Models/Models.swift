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
    let title: String
    let date: String // ISO8601 format
    let total_people: Int
    let total_amount: Double
    let items: [ReceiptItem]
    let image_url: String?
    let notes: String?
    let created_at: String
    let updated_at: String?
    let created_by: Int?
    let group_id: Int?
    let status: String?
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: date) {
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
        return date
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: total_amount)) ?? "$0.00"
    }
}

// MARK: - ReceiptItem
struct ReceiptItem: Codable, Identifiable {
    let id: Int
    let name: String
    let price: Double
    let receipt_id: Int?
    let created_at: String?
    let updated_at: String?
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

// MARK: - Trip
struct Trip: Identifiable, Codable {
    let id: Int
    let name: String
    let members: [User]
    let created_at: String
} 