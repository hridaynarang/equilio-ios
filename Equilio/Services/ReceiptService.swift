import Foundation

enum ReceiptError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case imageUploadError(Error)
}

class ReceiptService {
    static let shared = ReceiptService()
    private let baseURL = "http://localhost:3000/api"
    private let token: String
    
    private init() {
        self.token = AuthManager.shared.token ?? ""
    }
    
    func createReceipt(request: ReceiptCreateRequest) async throws -> Receipt {
        guard let url = URL(string: "\(baseURL)/receipts") else {
            throw ReceiptError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw ReceiptError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Receipt.self, from: data)
        } catch let error as DecodingError {
            throw ReceiptError.decodingError(error)
        } catch {
            throw ReceiptError.networkError(error)
        }
    }
    
    func getReceipts() async throws -> [Receipt] {
        guard let url = URL(string: "\(baseURL)/receipts") else {
            throw ReceiptError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw ReceiptError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Receipt].self, from: data)
        } catch let error as DecodingError {
            throw ReceiptError.decodingError(error)
        } catch {
            throw ReceiptError.networkError(error)
        }
    }
    
    func getReceipt(id: Int) async throws -> Receipt {
        guard let url = URL(string: "\(baseURL)/receipts/\(id)") else {
            throw ReceiptError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw ReceiptError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Receipt.self, from: data)
        } catch let error as DecodingError {
            throw ReceiptError.decodingError(error)
        } catch {
            throw ReceiptError.networkError(error)
        }
    }
} 