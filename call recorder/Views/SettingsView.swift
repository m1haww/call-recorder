import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var notificationsEnabled = true
    @State private var selectedLanguage = "English"
    @State private var selectedPlan = "monthly"
    @State private var showSubscriptionDetails = false
    @State private var showSignOutAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var userEmail = ""
    @State private var userName = ""
    
    let languages = ["English", "Spanish", "French", "German", "Chinese", "Japanese"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ProfileSection(userEmail: userEmail, userName: userName)
                    
                    NotificationsSection(notificationsEnabled: $notificationsEnabled)
                    
                    LanguageSection(selectedLanguage: $selectedLanguage, languages: languages)
                    
                    PrivacySection()
                    
                    SubscriptionSection(
                        selectedPlan: $selectedPlan,
                        showDetails: $showSubscriptionDetails
                    )
                    
                    LegalSection()
                    
                    AccountSection(
                        showSignOutAlert: $showSignOutAlert,
                        showDeleteAccountAlert: $showDeleteAccountAlert
                    )
                }
                .padding(.vertical)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .background(Color.darkBackground)
            .onAppear {
                loadUserData()
            }
        }
        .sheet(isPresented: $showSubscriptionDetails) {
            SubscriptionDetailsView(selectedPlan: $selectedPlan)
        }
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                // Handle account deletion
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
    }
    
    private func loadUserData() {
        if let currentUser = authManager.currentUser {
            userEmail = currentUser.email
            userName = currentUser.fullName
        }
    }
    
    private func signOut() {
        authManager.signOut()
    }
}

struct ProfileSection: View {
    let userEmail: String
    let userName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Profile", icon: "person.circle")
            
            VStack(spacing: 0) {
                HStack {
                    Circle()
                        .fill(Color.primaryGreen.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(userName.prefix(1).uppercased())
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primaryGreen)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(userName.isEmpty ? "User" : userName)
                            .font(.headline)
                            .foregroundColor(.primaryText)
                        
                        Text(userEmail)
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                    }
                    
                    Spacer()
                    
                    Button("Edit") {
                        // Handle edit profile
                    }
                    .font(.subheadline)
                    .foregroundColor(.primaryGreen)
                }
                .padding()
            }
            .background(Color.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.surfaceBackground, lineWidth: 1)
            )
        }
        .padding(.horizontal)
        .sheet(isPresented: $showEditSheet) {
            EditProfileView(
                userName: userName,
                userEmail: userEmail,
                userAvatar: $userAvatar
            )
        }
    }
}

struct NotificationsSection: View {
    @Binding var notificationsEnabled: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Notifications", icon: "bell")
            
            Toggle(isOn: $notificationsEnabled) {
                HStack {
                    Image(systemName: "bell.badge")
                        .foregroundColor(.skyBlue)
                    Text("Push Notifications")
                        .font(.subheadline)
                }
            }
            .tint(.primaryGreen)
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.surfaceBackground, lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }
}

struct LanguageSection: View {
    @Binding var selectedLanguage: String
    let languages: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Language", icon: "globe")
            
            VStack(spacing: 0) {
                ForEach(languages, id: \.self) { language in
                    Button(action: { selectedLanguage = language }) {
                        HStack {
                            Text(language)
                                .font(.subheadline)
                                .foregroundColor(.navyBlue)
                            
                            Spacer()
                            
                            if selectedLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.skyBlue)
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding()
                    }
                    
                    if language != languages.last {
                        Divider()
                            .padding(.leading)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

struct PrivacySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Privacy & Security", icon: "lock")
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "lock.shield",
                    title: "Data Encryption",
                    subtitle: "End-to-end encrypted"
                )
                
                Divider()
                    .padding(.leading, 56)
                
                SettingsRow(
                    icon: "hand.raised",
                    title: "Privacy Policy",
                    showChevron: true
                )
                
                Divider()
                    .padding(.leading, 56)
                
                SettingsRow(
                    icon: "doc.text",
                    title: "Data Usage",
                    showChevron: true
                )
            }
            .background(Color.white)
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

struct SubscriptionSection: View {
    @Binding var selectedPlan: String
    @Binding var showDetails: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Subscription", icon: "creditcard")
            
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Plan")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Pro Monthly")
                            .font(.headline)
                            .foregroundColor(.navyBlue)
                    }
                    
                    Spacer()
                    
                    Button("Change Plan") {
                        showDetails = true
                    }
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(.skyBlue)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                
                HStack(spacing: 12) {
                    PlanButton(
                        title: "Weekly",
                        price: "$4.99",
                        isSelected: selectedPlan == "weekly",
                        action: { selectedPlan = "weekly" }
                    )
                    
                    PlanButton(
                        title: "Monthly",
                        price: "$14.99",
                        isSelected: selectedPlan == "monthly",
                        action: { selectedPlan = "monthly" }
                    )
                    
                    PlanButton(
                        title: "Yearly",
                        price: "$99.99",
                        isSelected: selectedPlan == "yearly",
                        action: { selectedPlan = "yearly" }
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}

struct LegalSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Legal", icon: "doc.text.magnifyingglass")
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "doc.text",
                    title: "Terms of Service",
                    showChevron: true
                )
                
                Divider()
                    .padding(.leading, 56)
                
                SettingsRow(
                    icon: "questionmark.circle",
                    title: "Help & Support",
                    showChevron: true
                )
            }
            .background(Color.white)
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

struct AccountSection: View {
    @Binding var showSignOutAlert: Bool
    @Binding var showDeleteAccountAlert: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                showSignOutAlert = true
            }) {
                HStack {
                    Image(systemName: "arrow.right.square")
                    Text("Sign Out")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.cardBackground)
                .foregroundColor(.primaryText)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.surfaceBackground, lineWidth: 1)
                )
            }
            
            Button(action: {
                showDeleteAccountAlert = true
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Account")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.skyBlue)
                .font(.footnote)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.navyBlue)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var showChevron: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.skyBlue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.navyBlue)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(.darkGrey)
                    .font(.caption)
            }
        }
        .padding()
    }
}

struct PlanButton: View {
    let title: String
    let price: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(price)
                    .font(.footnote)
                    .fontWeight(.bold)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.skyBlue : Color.white)
            .foregroundColor(isSelected ? .white : .navyBlue)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.clear : Color.mediumGrey, lineWidth: 1)
            )
        }
    }
}

struct SubscriptionDetailsView: View {
    @Binding var selectedPlan: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.skyBlue)
                    
                    Text("Unlock Premium Features")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.navyBlue)
                    
                    Text("Get unlimited recordings and transcripts")
                        .font(.subheadline)
                        .foregroundColor(.darkGrey)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                VStack(spacing: 16) {
                    FeatureRow(icon: "infinity", text: "Unlimited recordings")
                    FeatureRow(icon: "text.bubble", text: "Full transcripts")
                    FeatureRow(icon: "icloud", text: "Cloud backup")
                    FeatureRow(icon: "bolt", text: "Priority support")
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: {}) {
                        Text("Try 3 Days Free")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.skyBlue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Text("Then \(priceForPlan(selectedPlan))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.skyBlue)
                }
            }
        }
    }
    
    func priceForPlan(_ plan: String) -> String {
        switch plan {
        case "weekly": return "$4.99/week"
        case "monthly": return "$14.99/month"
        case "yearly": return "$99.99/year"
        default: return "$14.99/month"
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.skyBlue)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.navyBlue)
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
}