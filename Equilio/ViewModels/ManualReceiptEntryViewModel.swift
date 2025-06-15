import Foundation
import SwiftUI
import Combine

@MainActor
class ManualReceiptEntryViewModel: ObservableObject {
    @Published var title = ""
    @Published var date = Date()
    @Published var totalPeople = 1
    @Published var notes = ""
    @Published var items: [ReceiptItem] = []
    @Published var selectedTrip: Trip?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingParticipantSelection = false
    
    // Computed properties
    var total: Double {
        items.reduce(0) { $0 + $1.price }
    }
    
    var amountPerPerson: Double {
        guard totalPeople > 0 else { return 0 }
        return total / Double(totalPeople)
    }
    
    // Methods
    func addItem(name: String, price: Double) {
        items.append(ReceiptItem(name: name, price: price))
    }
    
    func removeItem(at index: Int) {
        items.remove(at: index)
    }
    
    func submitReceipt() async {
        guard !title.isEmpty else {
            errorMessage = "Please enter a receipt title"
            return
        }
        
        guard !items.isEmpty else {
            errorMessage = "Please add at least one item"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Create the request
            let request = ReceiptCreateRequest(
                title: title,
                date: ISO8601DateFormatter().string(from: date),
                total_people: totalPeople,
                items: items.map { ReceiptCreateRequest.ReceiptItemCreate(name: $0.name, price: $0.price) },
                image_url: nil,
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
        items = []
        selectedTrip = nil
        errorMessage = nil
    }
} 