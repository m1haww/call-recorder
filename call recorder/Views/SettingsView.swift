import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = AppViewModel.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var notificationsEnabled = UserDefaults.standard.bool(forKey: "pushNotificationsEnabled")
    @State private var selectedPlan = "monthly"
    @State private var showSignOutAlert = false
    @State private var showDeleteAccountAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProfileSection(userPhoneNumber: viewModel.userPhoneNumber, userName: viewModel.userName)
                
                NotificationsSection(notificationsEnabled: $notificationsEnabled)
                
                LanguageSection()
                
                PrivacySection()
                
                LegalSection()
                
                AccountSection(
                    showSignOutAlert: $showSignOutAlert,
                    showDeleteAccountAlert: $showDeleteAccountAlert
                )
            }
            .padding(.vertical)
            .padding(.bottom, 80)
        }
        .preferredColorScheme(.dark)
        .background(Color.darkBackground)
        .onAppear {
            viewModel.loadUserData()
        }
        .alert(localizationManager.localizedString("delete_data"), isPresented: $showDeleteAccountAlert) {
            Button(localizationManager.localizedString("cancel"), role: .cancel) {}
            Button(localizationManager.localizedString("delete"), role: .destructive) {
                deleteUserData()
            }
        } message: {
            Text(localizationManager.localizedString("delete_data_message"))
        }
    }
    
    private func deleteUserData() {
        viewModel.recordings.removeAll()
        viewModel.showToast(localizationManager.localizedString("delete_data_success"))
    }
}

struct ProfileSection: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    let userPhoneNumber: String
    let userName: String
    @State private var showEditSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: localizationManager.localizedString("profile"), icon: "person.circle")
            
            VStack(spacing: 0) {
                HStack {
                    Circle()
                        .fill(Color.primaryGreen.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text((userName.isEmpty ? localizationManager.localizedString("user") : userName).prefix(1).uppercased())
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primaryGreen)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(userName.isEmpty ? localizationManager.localizedString("user") : userName)
                            .font(.headline)
                            .foregroundColor(.primaryText)
                        
                        Text(userPhoneNumber.isEmpty ? localizationManager.localizedString("no_phone_number") : userPhoneNumber)
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                    }
                    
                    Spacer()
                    
                    Button(localizationManager.localizedString("edit")) {
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
    @StateObject private var localizationManager = LocalizationManager.shared
    @Binding var notificationsEnabled: Bool
    @State private var isUpdating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @StateObject private var viewModel = AppViewModel.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: localizationManager.localizedString("notifications"), icon: "bell")
            
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
                        Text(localizationManager.localizedString("push_notifications"))
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
        .alert(localizationManager.localizedString("notification_error"), isPresented: $showError) {
            Button(localizationManager.localizedString("ok"), role: .cancel) {}
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

struct LanguageSection: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var showLanguagePicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: localizationManager.localizedString("language"), icon: "globe")
            
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
    @StateObject private var localizationManager = LocalizationManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: localizationManager.localizedString("privacy_security"), icon: "lock")
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "lock.shield",
                    title: localizationManager.localizedString("data_encryption"),
                    subtitle: localizationManager.localizedString("end_to_end_encrypted")
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
                        title: localizationManager.localizedString("privacy_policy"),
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
                        title: localizationManager.localizedString("data_usage"),
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
    @StateObject private var localizationManager = LocalizationManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: localizationManager.localizedString("legal"), icon: "doc.text.magnifyingglass")
            
            VStack(spacing: 0) {
                Button(action: {
                    if let url = URL(string: "https://docs.google.com/document/d/1VbemNFyZpawCaigbmEPzndAt3HN-iH4VsMH0Znsi-gU/edit?usp=sharing") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    SettingsRow(
                        icon: "doc.text",
                        title: localizationManager.localizedString("terms_service"),
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
                        title: localizationManager.localizedString("help_support"),
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
    @StateObject private var localizationManager = LocalizationManager.shared
    @Binding var showSignOutAlert: Bool
    @Binding var showDeleteAccountAlert: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                showDeleteAccountAlert = true
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text(localizationManager.localizedString("delete_data"))
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
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.primaryGreen)
                    
                    Text(localizationManager.localizedString("unlock_premium_features"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryText)
                    
                    Text(localizationManager.localizedString("unlock_premium_subtitle"))
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                VStack(spacing: 16) {
                    FeatureRow(icon: "infinity", text: localizationManager.localizedString("unlimited_recordings"))
                    FeatureRow(icon: "text.bubble", text: localizationManager.localizedString("full_transcripts"))
                    FeatureRow(icon: "icloud", text: localizationManager.localizedString("cloud_backup"))
                    FeatureRow(icon: "bolt", text: localizationManager.localizedString("priority_support"))
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: {
                        subscriptionService.showPaywall = true
                    }) {
                        Text(localizationManager.localizedString("try_3_days_free"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryGreen)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Text(localizationManager.localizedString("subscription_then").replacingOccurrences(of: "%@", with: priceForPlan("weekly")))
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .background(Color.cardBackground)
            .navigationTitle(localizationManager.localizedString("premium"))
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localizationManager.localizedString("done")) {
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
    @StateObject private var localizationManager = LocalizationManager.shared
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
            .navigationTitle(localizationManager.localizedString("language"))
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localizationManager.localizedString("done")) {
                        dismiss()
                    }
                    .foregroundColor(.primaryGreen)
                }
            }
            .onAppear {
                print("\(AppViewModel.shared.userId)")
            }
        }
    }
}
