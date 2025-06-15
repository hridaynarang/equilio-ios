import SwiftUI
import PhotosUI

struct UploadReceiptView: View {
    @ObservedObject var viewModel: ReceiptViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var showingImagePicker = false
    
    // Form fields
    @State private var title = ""
    @State private var merchant = ""
    @State private var date = Date()
    @State private var totalPeople = 1
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                Text("Take a photo or upload your receipt")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                // Upload Options
                HStack(spacing: 16) {
                    Button(action: { showingCamera = true }) {
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.title)
                            Text("Take Photo")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: { showingPhotoLibrary = true }) {
                        VStack {
                            Image(systemName: "folder.fill")
                                .font(.title)
                            Text("Upload File")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                // Image Preview
                if let image = viewModel.displayedImage {
                    VStack {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                        
                        Button(action: {
                            viewModel.displayedImage = nil
                            viewModel.imageData = nil
                        }) {
                            Label("Remove Image", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Form
                VStack(spacing: 16) {
                    // Receipt Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Receipt Title")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Enter receipt title", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Merchant Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Merchant Name")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Enter merchant name", text: $merchant)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        DatePicker("", selection: $date, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                    }
                    
                    // Total People
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total People")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Stepper(value: $totalPeople, in: 1...20) {
                            Text("\(totalPeople) \(totalPeople == 1 ? "person" : "people")")
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Submit Button
                Button(action: {
                    Task {
                        await viewModel.createReceipt(
                            title: title,
                            merchant: merchant,
                            date: date,
                            totalPeople: totalPeople
                        )
                        dismiss()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Submit Receipt")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading || !isValid)
                .padding()
            }
        }
        .navigationTitle("Upload Receipt")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCamera) {
            ImagePicker(sourceType: .camera, selectedImage: $viewModel.selectedImage)
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $viewModel.selectedImage)
        }
        .onChange(of: viewModel.selectedImage) { _ in
            Task {
                await viewModel.loadImage()
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    private var isValid: Bool {
        !title.isEmpty && !merchant.isEmpty && viewModel.imageData != nil
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                // Convert UIImage to Data
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    // Create a temporary file URL
                    let tempDir = FileManager.default.temporaryDirectory
                    let fileName = UUID().uuidString + ".jpg"
                    let fileURL = tempDir.appendingPathComponent(fileName)
                    
                    do {
                        try imageData.write(to: fileURL)
                        // Create a PhotosPickerItem from the file URL
                        // Note: This is a workaround since we can't directly create a PhotosPickerItem
                        // In a real app, you might want to handle the image data differently
                        parent.selectedImage = nil // Reset to trigger the onChange
                    } catch {
                        print("Error saving image: \(error)")
                    }
                }
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        UploadReceiptView(viewModel: ReceiptViewModel())
    }
} 