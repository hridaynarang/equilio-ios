import SwiftUI

struct ManualReceiptEntryView: View {
    @StateObject private var viewModel = ManualReceiptEntryViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddItem = false
    @State private var newItemName = ""
    @State private var newItemPrice = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Trip Selection (Optional)
                    if let trips = TripService.shared.trips {
                        Picker("Select Trip", selection: $viewModel.selectedTrip) {
                            Text("No Trip").tag(nil as Trip?)
                            ForEach(trips) { trip in
                                Text(trip.name).tag(trip as Trip?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    // Basic Info Section
                    VStack(spacing: 16) {
                        // Receipt Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Receipt Title")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextField("Enter receipt title", text: $viewModel.title)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        // Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            DatePicker("", selection: $viewModel.date, displayedComponents: [.date])
                                .datePickerStyle(.compact)
                        }
                        
                        // Total People
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Total People")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Stepper(value: $viewModel.totalPeople, in: 1...20) {
                                Text("\(viewModel.totalPeople) \(viewModel.totalPeople == 1 ? "person" : "people")")
                            }
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextEditor(text: $viewModel.notes)
                                .frame(height: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Items Section
                    VStack(spacing: 16) {
                        HStack {
                            Text("Items")
                                .font(.headline)
                            Spacer()
                            Button(action: { showingAddItem = true }) {
                                Label("Add Item", systemImage: "plus.circle.fill")
                            }
                        }
                        
                        if viewModel.items.isEmpty {
                            Text("No items added yet")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(viewModel.items) { item in
                                HStack {
                                    Text(item.name)
                                    Spacer()
                                    Text("$\(item.price, specifier: "%.2f")")
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            
                            // Dynamic Calculations
                            VStack(spacing: 12) {
                                Divider()
                                
                                // Total
                                HStack {
                                    Text("Total")
                                        .font(.headline)
                                    Spacer()
                                    Text("$\(viewModel.total, specifier: "%.2f")")
                                        .font(.headline)
                                }
                                
                                // Per Person
                                if viewModel.totalPeople > 1 {
                                    HStack {
                                        Text("Per Person")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text("$\(viewModel.amountPerPerson, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Text("Split between \(viewModel.totalPeople) people")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Continue Button
                    Button(action: {
                        Task {
                            await viewModel.submitReceipt()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Continue to Add Participants")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(viewModel.isLoading || !isValid)
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddItem) {
                NavigationStack {
                    Form {
                        TextField("Item Name", text: $newItemName)
                        TextField("Price", text: $newItemPrice)
                            .keyboardType(.decimalPad)
                    }
                    .navigationTitle("Add Item")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingAddItem = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                if let price = Double(newItemPrice) {
                                    viewModel.addItem(name: newItemName, price: price)
                                    newItemName = ""
                                    newItemPrice = ""
                                    showingAddItem = false
                                }
                            }
                            .disabled(newItemName.isEmpty || Double(newItemPrice) == nil)
                        }
                    }
                }
                .presentationDetents([.height(200)])
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .navigationDestination(isPresented: $viewModel.showingParticipantSelection) {
                // TODO: Replace with actual ParticipantSelectionView when implemented
                Text("Participant Selection")
                    .navigationTitle("Select Participants")
            }
        }
    }
    
    private var isValid: Bool {
        !viewModel.title.isEmpty && !viewModel.items.isEmpty
    }
}

#Preview {
    ManualReceiptEntryView()
} 