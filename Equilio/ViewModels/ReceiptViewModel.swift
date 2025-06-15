import Foundation
import SwiftUI
import PhotosUI

@MainActor
class ReceiptViewModel: ObservableObject {
    @Published var receipts: [Receipt] = []
    @Published var selectedReceipt: Receipt?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Form fields
    @Published var description = ""
    @Published var amount = ""
    @Published var selectedGroup: Group?
    @Published var selectedImage: PhotosPickerItem?
    @Published var displayedImage: Image?
    @Published var imageData: Data?
    
    private let networkManager = NetworkManager.shared
    private let s3Service = S3Service()
    
    func fetchReceipts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.receipts = try await networkManager.get<[Receipt]>("/receipts")
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func fetchReceiptDetail(id: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.selectedReceipt = try await networkManager.get<Receipt>("/receipts/\(id)")
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createReceipt(title: String, merchant: String, date: Date, totalPeople: Int) async {
        guard let imageData = imageData else {
            errorMessage = "Please select an image"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // First, upload the image to S3
            let imageUrl = try await s3Service.uploadImage(imageData)
            
            // Then, create the receipt with the image URL
            let receipt = try await networkManager.post<Receipt, Models.ReceiptCreateRequest>(
                "/receipts",
                body: Models.ReceiptCreateRequest(
                    title: title,
                    merchant: merchant,
                    date: date,
                    total_people: totalPeople,
                    image_url: imageUrl
                )
            )
            
            receipts.insert(receipt, at: 0)
            resetForm()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateReceipt(id: Int) async {
        guard validateInput() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            var formData: [String: Any] = [
                "description": description,
                "amount": Double(amount) ?? 0.0
            ]
            
            if let group = selectedGroup {
                formData["group_id"] = group.id
            }
            
            let receipt = try await networkManager.uploadMultipartFormData<Receipt>(
                endpoint: "/receipts/\(id)",
                formData: formData,
                imageData: imageData
            )
            
            if let index = receipts.firstIndex(where: { $0.id == id }) {
                receipts[index] = receipt
            }
            resetForm()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteReceipt(id: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await networkManager.delete("/receipts/\(id)")
            receipts.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadImage() async {
        guard let item = selectedImage else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                imageData = data
                if let uiImage = UIImage(data: data) {
                    displayedImage = Image(uiImage: uiImage)
                }
            }
        } catch {
            errorMessage = "Failed to load image: \(error.localizedDescription)"
        }
    }
    
    private func validateInput() -> Bool {
        guard !description.isEmpty else {
            errorMessage = "Please enter a description"
            return false
        }
        
        guard let amount = Double(amount), amount > 0 else {
            errorMessage = "Please enter a valid amount"
            return false
        }
        
        return true
    }
    
    private func resetForm() {
        description = ""
        amount = ""
        selectedGroup = nil
        selectedImage = nil
        displayedImage = nil
        imageData = nil
    }
} 