import Foundation
import SwiftUI
import PhotosUI
import Models

@MainActor
class AddReceiptViewModel: ObservableObject {
    @Published var description = ""
    @Published var amount = ""
    @Published var selectedGroup: Group?
    @Published var selectedImage: PhotosPickerItem?
    @Published var displayedImage: Image?
    @Published var imageData: Data?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingSuccess = false
    
    private let receiptService: ReceiptService
    let groups: [Group]
    
    init(token: String, groups: [Group]) {
        self.receiptService = ReceiptService(token: token)
        self.groups = groups
    }
    
    func submitReceipt() async {
        guard let group = selectedGroup else {
            errorMessage = "Please select a group"
            return
        }
        
        guard let amountDouble = Double(amount) else {
            errorMessage = "Please enter a valid amount"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await receiptService.createReceipt(
                description: description,
                amount: amountDouble,
                groupId: group.id,
                imageData: imageData
            )
            showingSuccess = true
            resetForm()
        } catch {
            errorMessage = "Failed to create receipt: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
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
            self.errorMessage = "Failed to load image: \(error.localizedDescription)"
        }
    }
    
    private func resetForm() {
        description = ""
        amount = ""
        selectedGroup = nil
        selectedImage = nil
        displayedImage = nil
        imageData = nil
    }
    
    var isValid: Bool {
        !description.isEmpty && !amount.isEmpty && selectedGroup != nil
    }
} 