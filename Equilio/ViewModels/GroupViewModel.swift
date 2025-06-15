import Foundation
import SwiftUI
import Models

@MainActor
class GroupViewModel: ObservableObject {
    @Published var groups: [Group] = []
    @Published var selectedGroup: GroupDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingCreateGroup = false
    @Published var newGroupName = ""
    
    private let networkManager = NetworkManager.shared
    
    func fetchGroups() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.groups = try await networkManager.get<[Group]>("/groups")
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func fetchGroupDetail(id: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.selectedGroup = try await networkManager.get<GroupDetail>("/groups/\(id)")
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createGroup() async {
        guard !newGroupName.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let group = try await networkManager.post<Group, [String: String]>(
                "/groups",
                body: ["name": newGroupName]
            )
            groups.append(group)
            showingCreateGroup = false
            newGroupName = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func addMember(groupId: Int, username: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await networkManager.post<Group, [String: String]>(
                "/groups/\(groupId)/members",
                body: ["username": username]
            )
            await fetchGroupDetail(id: groupId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func removeMember(groupId: Int, userId: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await networkManager.delete("/groups/\(groupId)/members/\(userId)")
            await fetchGroupDetail(id: groupId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
} 