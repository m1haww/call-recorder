import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = AppViewModel.shared
    @State private var notificationsEnabled = UserDefaults.standard.bool(forKey: "pushNotificationsEnabled")
    @State private var selectedPlan = "monthly"
    @State private var showSignOutAlert = false
    @State private var showDeleteAccountAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProfileSection(userPhoneNumber: viewModel.userPhoneNumber, userName: viewModel.userName)
                
                NotificationsSection(notificationsEnabled: $notificationsEnabled)
                
                PrivacySection()
                
                LegalSection()
                
                AccountSection(
                    showSignOutAlert: $showSignOutAlert,
                    showDeleteAccountAlert: $showDeleteAccountAlert
                )
            }
            .padding(.vertical)
            .padding(.bottom, 40)
        }
        .preferredColorScheme(.dark)
        .background(Color.darkBackground)
        .onAppear {
            viewModel.loadUserData()
        }
        .alert(String(localized: "Delete Data"), isPresented: $showDeleteAccountAlert) {
            Button(String(localized: "Cancel"), role: .cancel) {}
            Button(String(localized: "Delete"), role: .destructive) {
                deleteUserData()
            }
        } message: {
            Text(String(localized: "This action will delete all your recorded calls and data. Are you sure you want to continue?"))
        }
    }
    
    private func deleteUserData() {
        viewModel.recordings.removeAll()
        viewModel.showToast(String(localized: "All data deleted successfully"))
    }
}

struct ProfileSection: View {
    let userPhoneNumber: String
    let userName: String
    @State private var showEditSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: String(localized: "Profile"), icon: "person.circle")
            
            VStack(spacing: 0) {
                HStack {
                    Circle()
                        .fill(Color.primaryGreen.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text((userName.isEmpty ? String(localized: "User") : userName).prefix(1).uppercased())
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primaryGreen)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(userName.isEmpty ? String(localized: "User") : userName)
                            .font(.headline)
                            .foregroundColor(.primaryText)
                        
                        Text(userPhoneNumber.isEmpty ? String(localized: "No phone number") : userPhoneNumber)
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                    }
                    
                    Spacer()
                    
                    Button(String(localized: "Edit")) {
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
    @State private var isUpdating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @StateObject private var viewModel = AppViewModel.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: String(localized: "Notifications"), icon: "bell")
            
            HStack {
                Toggle(isOn: Binding(
                    get: { notificationsEnabled },
                    set: { newValue in
                        updateNotificationSettings(enabled: newValue)
                    }
                )) {
                    HStack {
                        Image(systemName: "bell.badge")
                            .foregroundColor(.primaryGreen)
                        Text(String(localized: "Push Notifications"))
                            .font(.subheadline)
                            .foregroundColor(.primaryText)
                    }
                }
                .tint(.primaryGreen)
                .disabled(isUpdating)
                
                if isUpdating {
                    ProgressView()
                        .scaleEffect(0.8)
                        .padding(.leading, 8)
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .alert(String(localized: "Notification Error"), isPresented: $showError) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func updateNotificationSettings(enabled: Bool) {
        isUpdating = true
        let previousValue = notificationsEnabled
        notificationsEnabled = enabled
        
        UserService.shared.updateNotificationSettings(userId: viewModel.userId, enabled: enabled) { result in
            isUpdating = false
            
            switch result {
            case .success(_):
                UserDefaults.standard.set(enabled, forKey: "pushNotificationsEnabled")
            case .failure(let error):
                notificationsEnabled = previousValue
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

struct PrivacySection: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: String(localized: "Privacy & Security"), icon: "lock")
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "lock.shield",
                    title: String(localized: "Data Encryption"),
                    subtitle: String(localized: "End-to-end encrypted")
                )
                
                Divider()
                    .background(Color.darkGrey.opacity(0.3))
                    .padding(.leading, 56)
                
                Button(action: {
                    if let url = URL(string: "https://docs.google.com/document/d/1uth_ytIH6sL8eJu1w2loQkPMonuRYz-c1yq5xkVK71k/edit?usp=sharing") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    SettingsRow(
                        icon: "hand.raised",
                        title: String(localized: "Privacy Policy"),
                        showChevron: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .background(Color.darkGrey.opacity(0.3))
                    .padding(.leading, 56)
                
                Button(action: {
                    if let url = URL(string: "https://docs.google.com/document/d/1uSdixI2AsQ32u3aMMekKI9M_eEJH2SNPcr8RLT_DS3Q/edit?usp=sharing") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    SettingsRow(
                        icon: "doc.text",
                        title: String(localized: "Data Usage"),
                        showChevron: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

struct LegalSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: String(localized: "Legal"), icon: "doc.text.magnifyingglass")
            
            VStack(spacing: 0) {
                Button(action: {
                    if let url = URL(string: "https://docs.google.com/document/d/1VbemNFyZpawCaigbmEPzndAt3HN-iH4VsMH0Znsi-gU/edit?usp=sharing") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    SettingsRow(
                        icon: "doc.text",
                        title: String(localized: "Terms of Service"),
                        showChevron: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .background(Color.darkGrey.opacity(0.3))
                    .padding(.leading, 56)
                
                Button(action: {
                    if let url = URL(string: "mailto:easterparsons1994@gmail.com?subject=Call%20Recorder%20Support") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    SettingsRow(
                        icon: "questionmark.circle",
                        title: String(localized: "Help & Support"),
                        showChevron: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
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
                    Text(String(localized: "Delete Data"))
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
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.primaryGreen)
                    
                    Text(String(localized: "Unlock Premium Features"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryText)
                    
                    Text(String(localized: "Get unlimited recordings and transcripts"))
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                VStack(spacing: 16) {
                    FeatureRow(icon: "infinity", text: String(localized: "Unlimited recordings"))
                    FeatureRow(icon: "text.bubble", text: String(localized: "Full transcripts"))
                    FeatureRow(icon: "icloud", text: String(localized: "Cloud backup"))
                    FeatureRow(icon: "bolt", text: String(localized: "Priority support"))
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: {
                        subscriptionService.showPaywall = true
                    }) {
                        Text(String(localized: "Try 3 Days Free"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryGreen)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Text(String(format: String(localized: "Then %@"), priceForPlan("weekly")))
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .background(Color.cardBackground)
            .navigationTitle(String(localized: "Premium"))
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "Done")) {
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
