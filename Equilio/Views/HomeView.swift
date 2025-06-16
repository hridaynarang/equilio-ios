import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @Environment(\.colorScheme) var colorScheme
    
    init(token: String) {
         self.viewModel = HomeViewModel(token: token)
     }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Message
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome back!")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Here's your expense summary")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Summary Cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            SummaryCard(
                                title: "You Owe",
                                amount: viewModel.summary?.you_owe ?? 0,
                                color: .red,
                                icon: "arrow.up.right"
                            )
                            
                            SummaryCard(
                                title: "Owed to You",
                                amount: viewModel.summary?.owed_to_you ?? 0,
                                color: .green,
                                icon: "arrow.down.right"
                            )
                            
                            SummaryCard(
                                title: "This Month",
                                amount: viewModel.summary?.this_month ?? 0,
                                color: .blue,
                                icon: "calendar"
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Recent Activity Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Activity")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        } else if viewModel.receipts.isEmpty {
                            EmptyStateView()
                        } else {
                            ForEach(viewModel.receipts) { receipt in
                                ReceiptRow(receipt: receipt)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await viewModel.fetchReceipts()
            }
            .task {
                await viewModel.fetchReceipts()
            }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Text("$\(String(format: "%.2f", amount))")
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(width: 160)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ReceiptRow: View {
    let receipt: Receipt
    
    var body: some View {
        HStack(spacing: 16) {
            // Receipt Image or Placeholder
            if let imageUrl = receipt.image_url {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 50, height: 50)
                .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(receipt.title)
                    .font(.headline)
                Text("$\(String(format: "%.2f", receipt.total_amount))")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                Text(formatDate(receipt.created_at))
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
        .padding(.horizontal)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM d, h:mm a"
            return formatter.string(from: date)
        }
        return dateString
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Recent Activity")
                .font(.headline)
            
            Text("Your recent receipts will appear here")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

#Preview {
    HomeView(token: "preview_token")
} 