import Foundation
import SwiftUI
import Models

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [User] = []
    @Published var groups: [Group] = []
    @Published var pendingRequests: [FriendRequest] = []
    @Published var recentMessages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: User?
    @Published var showingCreateGroup = false
    @Published var newGroupName = ""
    
    private let friendService: FriendService
    
    init(token: String) {
        self.friendService = FriendService(token: token)
    }
    
    func fetchData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await friendService.getFriends()
            self.friends = response.friends
            self.groups = response.groups
            self.pendingRequests = response.pending_requests
            self.recentMessages = response.recent_messages
            // Assuming the first user in friends list is the current user
            self.currentUser = response.friends.first
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func sendFriendRequest(username: String) async {
        do {
            try await friendService.sendFriendRequest(username: username)
            await fetchData() // Refresh data after sending request
        } catch {
            errorMessage = "Failed to send friend request: \(error.localizedDescription)"
        }
    }
    
    func createGroup() async {
        guard !newGroupName.isEmpty else { return }
        
        do {
            let newGroup = try await friendService.createGroup(name: newGroupName)
            groups.append(newGroup)
            newGroupName = ""
            showingCreateGroup = false
        } catch {
            errorMessage = "Failed to create group: \(error.localizedDescription)"
        }
    }
    
    func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM d, h:mm a"
            return formatter.string(from: date)
        }
        return dateString
    }
} 