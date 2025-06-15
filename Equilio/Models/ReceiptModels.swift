import Foundation

struct Receipt: Codable, Identifiable {
    let id: Int
    let title: String
    let date: Date
    let total_people: Int
    let total_amount: Double
    let items: [ReceiptItem]
    let image_url: String?
    let notes: String?
    let created_at: Date
    let updated_at: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case date
        case total_people
        case total_amount
        case items
        case image_url
        case notes
        case created_at
        case updated_at
    }
}

struct ReceiptItem: Codable, Identifiable {
    let id: Int
    let name: String
    let price: Double
    let receipt_id: Int
    let created_at: Date
    let updated_at: Date
}

struct ReceiptCreateRequest: Codable {
    let title: String
    let date: String // ISO8601 format
    let total_people: Int
    let items: [ReceiptItemCreate]
    let image_url: String?
    let notes: String?
    
    struct ReceiptItemCreate: Codable {
        let name: String
        let price: Double
    }
}

struct ReceiptSummary: Codable {
    let you_owe: Double
    let owed_to_you: Double
    let this_month: Double
}

struct ReceiptResponse: Codable {
    let receipts: [Receipt]
    let summary: ReceiptSummary
} 