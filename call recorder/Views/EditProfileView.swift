import SwiftUI

struct EditProfileView: View {
    let userName: String
    let phoneNumber: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var editedName: String = ""
    @State private var showSaveAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Profile Icon
                VStack(spacing: 16) {
                    Circle()
                        .fill(Color.primaryGreen.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(editedName.prefix(1).uppercased())
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryGreen)
                        )
                    
                    Text("Edit your profile name")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                .padding(.top, 20)
                
                // Form Fields
                VStack(spacing: 16) {
                    // Full Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primaryText)
                        
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(.secondaryText)
                            
                            TextField("Enter your full name", text: $editedName)
                                .foregroundColor(.primaryText)
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.surfaceBackground, lineWidth: 1)
                        )
                    }
                    
                    // Phone Number Field (Read-only)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Phone Number")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primaryText)
                        
                        HStack {
                            Image(systemName: "phone")
                                .foregroundColor(.secondaryText)
                            
                            Text(phoneNumber)
                                .foregroundColor(.secondaryText)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.cardBackground.opacity(0.5))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.surfaceBackground, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Save Button
                Button(action: {
                    UserDefaults.standard.set(editedName, forKey: "userName")
                    showSaveAlert = true
                }) {
                    Text("Save Changes")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.primaryGreen, .accentGreen]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                }
                .padding(.horizontal)
                .disabled(editedName.isEmpty)
                .opacity(editedName.isEmpty ? 0.6 : 1.0)
            }
            .background(Color.darkBackground)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primaryGreen)
                }
            }
            .onAppear {
                editedName = userName
            }
        }
        .alert("Profile Updated", isPresented: $showSaveAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your profile has been updated successfully.")
        }
    }
}

#Preview {
    EditProfileView(
        userName: "John Doe",
        phoneNumber: "+1234567890"
    )
}