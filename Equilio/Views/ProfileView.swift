import SwiftUI
import Models

struct ProfileView: View {
    let token: String
    @StateObject private var viewModel: ProfileViewModel
    
    init(token: String) {
        self.token = token
        _viewModel = StateObject(wrappedValue: ProfileViewModel(token: token))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // User Info Section
                    VStack(spacing: 8) {
                        Text(viewModel.profile?.username ?? "")
                            .font(.title)
                            .bold()
                        Text(viewModel.profile?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    // Stats Section
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(title: "Total Receipts", value: "\(viewModel.profile?.stats.total_receipts ?? 0)")
                        StatCard(title: "Total Amount", value: viewModel.formatCurrency(viewModel.profile?.stats.total_amount ?? 0))
                        StatCard(title: "Active", value: "\(viewModel.profile?.stats.active_receipts ?? 0)")
                        StatCard(title: "Settled", value: "\(viewModel.profile?.stats.settled_receipts ?? 0)")
                    }
                    .padding(.horizontal)
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        Button(action: { viewModel.showingEditProfile = true }) {
                            Label("Edit Profile", systemImage: "pencil")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: { viewModel.showingFriends = true }) {
                            Label("Manage Friends", systemImage: "person.2")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)
                    
                    // Recent Receipts
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Receipts")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if let receipts = viewModel.profile?.recent_receipts, !receipts.isEmpty {
                            ForEach(receipts) { receipt in
                                ReceiptRow(receipt: receipt, viewModel: viewModel)
                            }
                        } else {
                            Text("No recent receipts")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .refreshable {
                await viewModel.fetchProfile()
            }
            .task {
                await viewModel.fetchProfile()
            }
            .sheet(isPresented: $viewModel.showingEditProfile) {
                EditProfileView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingFriends) {
                FriendsView(token: token)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ReceiptRow: View {
    let receipt: Receipt
    let viewModel: ProfileViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(receipt.description)
                    .font(.headline)
                Text(viewModel.formatDate(receipt.created_at))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(viewModel.formatCurrency(receipt.amount))
                .font(.headline)
                .foregroundColor(receipt.status == "settled" ? .green : .primary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    @State private var username: String = ""
    @State private var email: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Username", text: $username)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.updateProfile(username: username, email: email)
                        }
                    }
                    .disabled(username.isEmpty || email.isEmpty)
                }
            }
            .onAppear {
                username = viewModel.profile?.username ?? ""
                email = viewModel.profile?.email ?? ""
            }
        }
    }
}

#Preview {
    ProfileView(token: "sample_token")
} 