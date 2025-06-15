import Foundation
import SwiftUI
import PhotosUI

@MainActor
class UploadReceiptViewModel: ObservableObject {
    @Published var title = ""
    @Published var date = Date()
    @Published var totalPeople = 1
    @Published var notes = ""
    @Published var selectedImage: PhotosPickerItem?
    @Published var displayedImage: Image?
    @Published var imageData: Data?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingParticipantSelection = false
    
    func loadImage() async {
        guard let selectedImage = selectedImage else { return }
        
        do {
            if let data = try await selectedImage.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    displayedImage = Image(uiImage: uiImage)
                    imageData = data
                }
            }
        } catch {
            errorMessage = "Failed to load image: \(error.localizedDescription)"
        }
    }
    
    func submitReceipt() async {
        guard !title.isEmpty else {
            errorMessage = "Please enter a receipt title"
            return
        }
        
        guard let imageData = imageData else {
            errorMessage = "Please select an image"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Upload image to S3
            let imageUrl = try await S3Service.shared.uploadImage(imageData)
            
            // Create the request
            let request = ReceiptCreateRequest(
                title: title,
                date: ISO8601DateFormatter().string(from: date),
                total_people: totalPeople,
                items: [], // No items for uploaded receipts
                image_url: imageUrl,
                notes: notes.isEmpty ? nil : notes
            )
            
            // Submit the receipt
            let receipt = try await ReceiptService.shared.createReceipt(request: request)
            
            // Show participant selection
            showingParticipantSelection = true
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func resetForm() {
        title = ""
        date = Date()
        totalPeople = 1
        notes = ""
        selectedImage = nil
        displayedImage = nil
        imageData = nil
        errorMessage = nil
    }
} 