import Foundation

enum S3Error: Error {
    case invalidURL
    case uploadFailed
    case invalidResponse
    case networkError(Error)
}

class S3Service {
    static let shared = S3Service()
    private let networkManager = NetworkManager.shared
    
    func uploadImage(_ imageData: Data) async throws -> String {
        // First, get a presigned URL from our backend
        let presignedURLResponse = try await networkManager.get<PresignedURLResponse>("/upload/presigned-url")
        
        // Upload the image to S3 using the presigned URL
        guard let url = URL(string: presignedURLResponse.upload_url) else {
            throw S3Error.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw S3Error.uploadFailed
            }
            
            // Return the final URL where the image can be accessed
            return presignedURLResponse.final_url
        } catch {
            throw S3Error.networkError(error)
        }
    }
}

// Response from our backend for presigned URL
struct PresignedURLResponse: Codable {
    let upload_url: String
    let final_url: String
} 