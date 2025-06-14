import SwiftUI

struct SettingsView: View {
    @ObservedObject private var viewModel = AppViewModel.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var notificationsEnabled = true
    @State private var selectedPlan = "monthly"
    @State private var showSubscriptionDetails = false
    @State private var showSignOutAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var userEmail = ""
    @State private var userName = ""
    @State private var userPhoneNumber = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ProfileSection(userPhoneNumber: userPhoneNumber, userName: userName)
                    
                    NotificationsSection(notificationsEnabled: $notificationsEnabled)
                    
                    LanguageSection()
                    
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
            .navigationTitle(localized("settings"))
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .background(Color.darkBackground)
            .onAppear {
                loadUserData()
            }
        }
        .sheet(isPresented: $showSubscriptionDetails) {
            SubscriptionDetailsView()
        }
        .alert("Delete Data", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteUserData()
            }
        } message: {
            Text("This action will delete all your recorded calls and data. Are you sure you want to continue?")
        }
    }
    
    private func loadUserData() {
        userPhoneNumber = viewModel.userPhoneNumber
        userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        userName = UserDefaults.standard.string(forKey: "userName") ?? "User"
    }
    
    private func deleteUserData() {
        // Clear all user data
        viewModel.recordings.removeAll()
        viewModel.showToast("All data deleted successfully")
    }
}

struct ProfileSection: View {
    let userPhoneNumber: String
    let userName: String
    @State private var showEditSheet = false
    
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
                        
                        Text(userPhoneNumber.isEmpty ? "No phone number" : userPhoneNumber)
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                    }
                    
                    Spacer()
                    
                    Button("Edit") {
                        showEditSheet = true
                    }
                    .font(.subheadline)
                    .foregroundColor(.primaryGreen)
                }
                .padding()
            }
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .sheet(isPresented: $showEditSheet) {
            EditProfileView(userName: userName, phoneNumber: userPhoneNumber)
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
                        .foregroundColor(.primaryGreen)
                    Text("Push Notifications")
                        .font(.subheadline)
                        .foregroundColor(.primaryText)
                }
            }
            .tint(.primaryGreen)
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

struct LanguageSection: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var showLanguagePicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: localized("language"), icon: "globe")
            
            Button(action: {
                showLanguagePicker = true
            }) {
                HStack {
                    Text(localizationManager.currentLanguage.displayName)
                        .font(.subheadline)
                        .foregroundColor(.primaryText)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondaryText)
                        .font(.caption)
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerView()
        }
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
                    .background(Color.darkGrey.opacity(0.3))
                    .padding(.leading, 56)
                
                SettingsRow(
                    icon: "hand.raised",
                    title: "Privacy Policy",
                    showChevron: true
                )
                
                Divider()
                    .background(Color.darkGrey.opacity(0.3))
                    .padding(.leading, 56)
                
                SettingsRow(
                    icon: "doc.text",
                    title: "Data Usage",
                    showChevron: true
                )
            }
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

struct SubscriptionSection: View {
    @Binding var selectedPlan: String
    @Binding var showDetails: Bool
    @ObservedObject var viewModel = AppViewModel.shared
    
    var planText: String {
        switch viewModel.currentUser {
        case .free:
            return "Free Plan"
        case .premium:
            return "Premium Plan"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Subscription", icon: "creditcard")
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Plan")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                    Text(planText)
                        .font(.headline)
                        .foregroundColor(.primaryText)
                }
                
                Spacer()
                
                if viewModel.currentUser == .free {
                    Button("Upgrade") {
                        showDetails = true
                    }
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(.primaryGreen)
                } else {
                    Button("Manage") {
                        showDetails = true
                    }
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(.primaryGreen)
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
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
                    .background(Color.darkGrey.opacity(0.3))
                    .padding(.leading, 56)
                
                SettingsRow(
                    icon: "questionmark.circle",
                    title: "Help & Support",
                    showChevron: true
                )
            }
            .background(Color.cardBackground)
            .cornerRadius(12)
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
                showDeleteAccountAlert = true
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Data")
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
                .foregroundColor(.primaryGreen)
                .font(.footnote)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primaryText)
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
                .foregroundColor(.primaryGreen)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primaryText)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
            }
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondaryText)
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
            .background(isSelected ? Color.primaryGreen : Color.cardBackground)
            .foregroundColor(isSelected ? .white : .primaryText)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.clear : Color.darkGrey.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct SubscriptionDetailsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.primaryGreen)
                    
                    Text("Unlock Premium Features")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryText)
                    
                    Text("Get unlimited recordings and transcripts")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
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
                            .background(Color.primaryGreen)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Text("Then \(priceForPlan("weekly"))")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .background(Color.cardBackground)
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryGreen)
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
                .foregroundColor(.primaryGreen)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primaryText)
            
            Spacer()
        }
    }
}

struct LanguagePickerView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ForEach(LocalizationManager.Language.allCases) { language in
                    Button(action: {
                        localizationManager.setLanguage(language)
                        HapticManager.shared.selection()
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(language.displayName)
                                    .font(.body)
                                    .foregroundColor(.primaryText)
                                
                                Text(language.nativeName)
                                    .font(.caption)
                                    .foregroundColor(.secondaryText)
                            }
                            
                            Spacer()
                            
                            if localizationManager.currentLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.primaryGreen)
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding()
                    }
                    
                    if language != LocalizationManager.Language.allCases.last {
                        Divider()
                            .background(Color.darkGrey.opacity(0.3))
                            .padding(.leading)
                    }
                }
                
                Spacer()
            }
            .background(Color.darkBackground)
            .navigationTitle(localized("settings"))
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryGreen)
                }
            }
        }
    }
}
