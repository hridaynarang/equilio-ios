import SwiftUI
import Models

struct FriendsView: View {
    @StateObject private var viewModel: FriendsViewModel
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    init(token: String) {
        _viewModel = StateObject(wrappedValue: FriendsViewModel(token: token))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // User Profile Header
                if let currentUser = viewModel.currentUser {
                    HStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(String(currentUser.username.prefix(1)).uppercased())
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(currentUser.username)
                                .font(.headline)
                            Text(currentUser.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemBackground))
                }
                
                // Tab View
                Picker("View", selection: $selectedTab) {
                    Text("Friends").tag(0)
                    Text("Add Friend").tag(1)
                    Text("Requests").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                TabView(selection: $selectedTab) {
                    FriendsListView(viewModel: viewModel)
                        .tag(0)
                    
                    AddFriendView(viewModel: viewModel)
                        .tag(1)
                    
                    RequestsView(viewModel: viewModel)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await viewModel.fetchData()
            }
            .task {
                await viewModel.fetchData()
            }
        }
    }
}

struct FriendsListView: View {
    @ObservedObject var viewModel: FriendsViewModel
    @State private var showingCreateGroup = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Groups Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Groups")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: { showingCreateGroup = true }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                        }
                    }
                    
                    if viewModel.groups.isEmpty {
                        Text("No groups yet")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(viewModel.groups) { group in
                            GroupRow(group: group)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Messages Preview Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Messages")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    if viewModel.recentMessages.isEmpty {
                        Text("No messages yet")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(viewModel.recentMessages) { message in
                            MessageRow(message: message)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showingCreateGroup) {
            CreateGroupView(viewModel: viewModel)
        }
    }
}

struct GroupRow: View {
    let group: Group
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(group.name.prefix(1)).uppercased())
                        .font(.headline)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.headline)
                Text("\(group.members.count) members")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct MessageRow: View {
    let message: Message
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(message.sender.username.prefix(1)).uppercased())
                        .font(.headline)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(message.sender.username)
                    .font(.headline)
                Text(message.content)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct AddFriendView: View {
    @ObservedObject var viewModel: FriendsViewModel
    @State private var username = ""
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                Task {
                    await viewModel.sendFriendRequest(username: username)
                    username = ""
                }
            }) {
                Text("Send Friend Request")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .disabled(username.isEmpty)
            
            Spacer()
        }
        .padding(.top)
    }
}

struct RequestsView: View {
    @ObservedObject var viewModel: FriendsViewModel
    
    var body: some View {
        List {
            if viewModel.pendingRequests.isEmpty {
                Text("No pending requests")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(viewModel.pendingRequests) { request in
                    RequestRow(request: request)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct RequestRow: View {
    let request: FriendRequest
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(request.sender.username.prefix(1)).uppercased())
                        .font(.headline)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(request.sender.username)
                    .font(.headline)
                Text("Wants to be your friend")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
                
                Button(action: {}) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct CreateGroupView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: FriendsViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group Information")) {
                    TextField("Group Name", text: $viewModel.newGroupName)
                }
            }
            .navigationTitle("Create Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        Task {
                            await viewModel.createGroup()
                            dismiss()
                        }
                    }
                    .disabled(viewModel.newGroupName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    FriendsView(token: "preview_token")
} 