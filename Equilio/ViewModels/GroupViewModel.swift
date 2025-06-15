import Foundation
import SwiftUI

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
            let groups: [Group] = try await networkManager.get("/groups")
            self.groups = groups
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func fetchGroupDetail(id: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let groupDetail: GroupDetail = try await networkManager.get("/groups/\(id)")
            self.selectedGroup = groupDetail
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
            let group: Group = try await networkManager.post("/groups", body: ["name": newGroupName])
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
            _ = try await networkManager.post("/groups/\(groupId)/members", body: ["username": username]) as Group
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