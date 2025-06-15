import Foundation
import SwiftUI
import Models

@MainActor
class HomeViewModel: ObservableObject {
    @Published var recentReceipts: [Receipt] = []
    @Published var activeGroups: [Group] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedTab = 0
    
    private let networkManager = NetworkManager.shared
    
    func fetchData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let receiptsTask = networkManager.get<[Receipt]>("/receipts/recent")
            async let groupsTask = networkManager.get<[Group]>("/groups/active")
            
            let (receipts, groups) = try await (receiptsTask, groupsTask)
            
            self.recentReceipts = receipts
            self.activeGroups = groups
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await fetchData()
    }
    
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
} 