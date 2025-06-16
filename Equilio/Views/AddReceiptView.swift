import SwiftUI
import PhotosUI

struct AddReceiptView: View {
    @StateObject private var viewModel = ReceiptViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Add New Receipt")
                        .font(.title)
                        .bold()
                    Text("Choose how you want to add your receipt")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top)
                
                // Options
                VStack(spacing: 16) {
                    NavigationLink(destination: UploadReceiptView(viewModel: viewModel)) {
                        OptionCard(
                            title: "Take Photo or Upload",
                            description: "Use your camera or select from your photo library",
                            systemImage: "camera.fill"
                        )
                    }
                    
                    NavigationLink(destination: ManualReceiptEntryView()) {
                        OptionCard(
                            title: "Enter Manually",
                            description: "Type in the receipt details yourself",
                            systemImage: "keyboard"
                        )
                    }
                }
                .padding(.horizontal)
                
                // Pro Tip
                VStack(alignment: .leading, spacing: 8) {
                    Label("Pro Tip", systemImage: "lightbulb.fill")
                        .font(.headline)
                        .foregroundColor(.yellow)
                    
                    Text("Taking a photo of your receipt allows us to automatically extract the details for you!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct OptionCard: View {
    let title: String
    let description: String
    let systemImage: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
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

#Preview {
    AddReceiptView()
} 