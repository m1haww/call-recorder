import SwiftUI
import AppsFlyerLib

struct AppsFlyerPrivacySettingsView: View {
    @State private var hasConsent = AppsFlyerPrivacyManager.shared.hasUserConsent
    @State private var isAnonymized = AppsFlyerPrivacyManager.shared.isAnonymized
    @State private var installOnlyMode = AppsFlyerPrivacyManager.shared.installOnlyMode
    @State private var disableIDFA = false
    @State private var disableIDFV = false
    @State private var showingResetAlert = false
    @State private var showingConsentDialog = false
    
    // Partner blocking states
    @State private var blockFacebook = false
    @State private var blockGoogle = false
    @State private var blockTikTok = false
    
    var body: some View {
        Form {
            // MARK: - Consent Section
            Section {
                Toggle("Analytics Consent", isOn: $hasConsent)
                    .onChange(of: hasConsent) { newValue in
                        AppsFlyerPrivacyManager.shared.hasUserConsent = newValue
                        if !newValue {
                            // If consent is revoked, show options
                            showingConsentDialog = true
                        }
                    }
                
                Text("When enabled, allows collection of app usage data for analytics and attribution")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("User Consent")
            }
            
            // MARK: - Privacy Mode Section
            Section {
                Toggle("Anonymous Mode", isOn: $isAnonymized)
                    .onChange(of: isAnonymized) { newValue in
                        AppsFlyerPrivacyManager.shared.isAnonymized = newValue
                    }
                    .disabled(!hasConsent)
                
                Toggle("Install Only Mode", isOn: $installOnlyMode)
                    .onChange(of: installOnlyMode) { newValue in
                        AppsFlyerPrivacyManager.shared.installOnlyMode = newValue
                    }
                    .disabled(!hasConsent)
                
                Text("Anonymous Mode: Removes all identifying information\nInstall Only Mode: Tracks only the install event")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("Privacy Modes")
            }
            
            // MARK: - Identifier Control
            Section {
                Toggle("Disable IDFA Collection", isOn: $disableIDFA)
                    .onChange(of: disableIDFA) { newValue in
                        AppsFlyerPrivacyManager.shared.disableAdvertisingIdentifier(newValue)
                    }
                    .disabled(!hasConsent)
                
                Toggle("Disable IDFV Collection", isOn: $disableIDFV)
                    .onChange(of: disableIDFV) { newValue in
                        AppsFlyerPrivacyManager.shared.disableIDFVCollection(newValue)
                    }
                    .disabled(!hasConsent)
            } header: {
                Text("Device Identifiers")
            } footer: {
                Text("Disabling identifiers may affect attribution accuracy")
                    .font(.caption)
            }
            
            // MARK: - Partner Sharing
            Section {
                Toggle("Block Facebook", isOn: $blockFacebook)
                    .onChange(of: blockFacebook) { newValue in
                        if newValue {
                            AppsFlyerPrivacyManager.shared.blockPartners([AppsFlyerPrivacyManager.CommonPartners.facebook])
                        } else {
                            AppsFlyerPrivacyManager.shared.unblockPartners([AppsFlyerPrivacyManager.CommonPartners.facebook])
                        }
                    }
                    .disabled(!hasConsent)
                
                Toggle("Block Google", isOn: $blockGoogle)
                    .onChange(of: blockGoogle) { newValue in
                        if newValue {
                            AppsFlyerPrivacyManager.shared.blockPartners([AppsFlyerPrivacyManager.CommonPartners.google])
                        } else {
                            AppsFlyerPrivacyManager.shared.unblockPartners([AppsFlyerPrivacyManager.CommonPartners.google])
                        }
                    }
                    .disabled(!hasConsent)
                
                Toggle("Block TikTok", isOn: $blockTikTok)
                    .onChange(of: blockTikTok) { newValue in
                        if newValue {
                            AppsFlyerPrivacyManager.shared.blockPartners([AppsFlyerPrivacyManager.CommonPartners.tiktok])
                        } else {
                            AppsFlyerPrivacyManager.shared.unblockPartners([AppsFlyerPrivacyManager.CommonPartners.tiktok])
                        }
                    }
                    .disabled(!hasConsent)
                
                Button("Block All Partners") {
                    AppsFlyerPrivacyManager.shared.blockAllPartners()
                    blockFacebook = true
                    blockGoogle = true
                    blockTikTok = true
                }
                .disabled(!hasConsent)
            } header: {
                Text("Third-Party Data Sharing")
            } footer: {
                Text("Control which advertising partners receive your data")
                    .font(.caption)
            }
            
            // MARK: - Actions
            Section {
                Button(action: {
                    showingResetAlert = true
                }) {
                    Text("Reset All Privacy Settings")
                        .foregroundColor(.red)
                }
            }
            
            // MARK: - Status
            Section {
                if let status = AppsFlyerPrivacyManager.shared.getCurrentPrivacyStatus() as? [String: Any] {
                    HStack {
                        Text("SDK Status")
                        Spacer()
                        Text((status["isSDKStopped"] as? Bool) == true ? "Stopped" : "Active")
                            .foregroundColor((status["isSDKStopped"] as? Bool) == true ? .red : .green)
                    }
                    
                    if hasConsent {
                        HStack {
                            Text("Privacy Level")
                            Spacer()
                            Text(getPrivacyLevel())
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } header: {
                Text("Current Status")
            }
        }
        .navigationTitle("AppsFlyer Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset Privacy Settings", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllSettings()
            }
        } message: {
            Text("This will reset all privacy settings and stop data collection. Are you sure?")
        }
        .sheet(isPresented: $showingConsentDialog) {
            ConsentDialogView(isPresented: $showingConsentDialog, hasConsent: $hasConsent)
        }
    }
    
    private func getPrivacyLevel() -> String {
        if isAnonymized {
            return "Anonymous"
        } else if installOnlyMode {
            return "Minimal"
        } else if blockFacebook || blockGoogle || blockTikTok {
            return "Restricted"
        } else {
            return "Standard"
        }
    }
    
    private func resetAllSettings() {
        AppsFlyerPrivacyManager.shared.resetAllPrivacySettings()
        hasConsent = false
        isAnonymized = false
        installOnlyMode = false
        disableIDFA = false
        disableIDFV = false
        blockFacebook = false
        blockGoogle = false
        blockTikTok = false
    }
}

// MARK: - Consent Dialog View

struct ConsentDialogView: View {
    @Binding var isPresented: Bool
    @Binding var hasConsent: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "shield.checkerboard")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Analytics & Privacy")
                    .font(.title2)
                    .bold()
                
                Text("We use AppsFlyer to understand how you use our app and improve your experience. Your privacy is important to us.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    Label("Anonymous analytics data", systemImage: "chart.bar")
                    Label("App performance metrics", systemImage: "speedometer")
                    Label("No personal information", systemImage: "person.crop.circle.badge.xmark")
                    Label("You can opt-out anytime", systemImage: "hand.raised")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: {
                        hasConsent = true
                        isPresented = false
                    }) {
                        Text("Accept Analytics")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        hasConsent = false
                        isPresented = false
                    }) {
                        Text("Decline")
                            .frame(maxWidth: .infinity)
                            .padding()
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
    }
}

// MARK: - Preview

struct AppsFlyerPrivacySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AppsFlyerPrivacySettingsView()
        }
    }
}