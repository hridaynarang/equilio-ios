import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(token: AuthManager.shared.token ?? "")
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            FriendsView(token: AuthManager.shared.token ?? "")
                .tabItem {
                    Label("Friends", systemImage: "person.3.fill")
                }
                .tag(1)
            
            AddReceiptView()
                .tabItem {
                    Label("Add Receipt", systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            ProfileView(token: AuthManager.shared.token ?? "")
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
    }
}

#Preview {
    MainTabView()
} 