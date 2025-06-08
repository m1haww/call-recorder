import SwiftUI

struct EditProfileView: View {
    let userName: String
    let userEmail: String
    @Binding var userAvatar: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    @State private var editedName: String = ""
    @State private var editedEmail: String = ""
    @State private var showSaveAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Avatar Section
                VStack(spacing: 16) {
                    AvatarImagePicker(selectedImage: $userAvatar)
                    
                    Text("Tap to change profile picture")
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
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primaryText)
                        
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.secondaryText)
                            
                            TextField("Enter your email", text: $editedEmail)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
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
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Save Button
                Button(action: {
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
                editedEmail = userEmail
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
        userEmail: "john@example.com",
        userAvatar: .constant(nil)
    )
}