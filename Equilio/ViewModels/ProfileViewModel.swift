import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingEditProfile = false
    @Published var showingFriends = false
    
    private let profileService: ProfileService
    
    init(token: String) {
        self.profileService = ProfileService(token: token)
    }
    
    func fetchProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.profile = try await profileService.getProfile()
        } catch {
            errorMessage = "Failed to load profile: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateProfile(username: String, email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.profile = try await profileService.updateProfile(username: username, email: email)
            showingEditProfile = false
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
        return dateString
    }
} 