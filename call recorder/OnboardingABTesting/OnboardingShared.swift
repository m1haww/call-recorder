import SwiftUI
import StoreKit

enum OnboardingABVariant: String, CaseIterable {
    case a
    case b
    case c
    case d
}

struct OnboardingStep: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
}

struct PhoneSelectionView: View {
    @StateObject private var viewModel = AppViewModel.shared
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    @State private var phoneNumber = ""
    @State private var selectedCountry = Country.defaultCountry
    @State private var showCountryPicker = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @FocusState private var isTextFieldFocused: Bool
    
    private func onComplete() {
        if isValidPhoneNumber(phoneNumber) {
            registerUser()
        } else {
            HapticManager.shared.notification(.error)
            showError = true
            errorMessage = String(format: String(localized: "Please enter a valid phone number for %@"), selectedCountry.name)
        }
    }
    
    private func registerUser() {
        let fullPhoneNumber = selectedCountry.dialCode + phoneNumber
        isLoading = true
        
        Task {
            do {
                try await UserService.shared.registerUser(
                    fcmToken: viewModel.fcmToken,
                    phoneNumber: fullPhoneNumber,
                    countryCode: self.selectedCountry.code,
                    userName: viewModel.userName
                )
                
                await viewModel.loadUserDataFromServer()
                
                self.isLoading = false
                self.viewModel.toggleRegisterStatus()
                
                withAnimation {
                    self.viewModel.showPhoneSelection = false
                }
            } catch {
                self.isLoading = false
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.error)
                self.showError = true
                self.errorMessage = String(format: String(localized: "Registration failed: %@"), error.localizedDescription)
            }
        }
    }
    
    private func isValidPhoneNumber(_ number: String) -> Bool {
        let cleaned = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return cleaned.count >= 7 && cleaned.count <= 15 && !cleaned.isEmpty
    }
    
    private var canProceed: Bool {
        return isValidPhoneNumber(phoneNumber) && !isLoading
    }
    
    var body: some View {
        ZStack {
            Color.darkBackground
                .ignoresSafeArea()
                .onTapGesture { isTextFieldFocused = false }
            
            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 44)

                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.primaryGreen, Color.accentGreen],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .shadow(color: Color.primaryGreen.opacity(0.45), radius: 20, x: 0, y: 8)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.primaryGreen.opacity(0.8),
                                                Color.accentGreen.opacity(0.5)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )

                        Image(systemName: "phone.fill")
                            .font(.system(size: 44, weight: .medium))
                            .foregroundColor(.white)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .padding(.bottom, 32)
                    
                    Text(String(localized: "Enter your phone number without the country code"))
                        .font(.body)
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                        .padding(.horizontal, 16)

                    VStack(spacing: 20) {
                        Button(action: {
                            HapticManager.shared.selection()
                            withAnimation { showCountryPicker = true }
                        }) {
                            HStack(spacing: 12) {
                                Text(selectedCountry.flag)
                                    .font(.title2)
                                Text(selectedCountry.name)
                                    .font(.title3)
                                    .foregroundColor(.primaryText)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondaryText)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 16)
                            .background(Color.cardBackground)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.surfaceBackground.opacity(0.8), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 4) {
                                Text(selectedCountry.dialCode)
                                    .font(.title3)
                                    .foregroundColor(.secondaryText)
                                    .padding(.leading, 18)

                                ZStack(alignment: .leading) {
                                    TextField("", text: $phoneNumber)
                                        .font(.title3)
                                        .foregroundColor(.primaryText)
                                        .padding(.trailing, 18)
                                        .keyboardType(.phonePad)
                                        .textContentType(.telephoneNumber)
                                        .padding(.leading, 8)
                                        .focused($isTextFieldFocused)
                                    
                                    if phoneNumber.isEmpty {
                                        Text(String(localized: "Phone number"))
                                            .font(.title3)
                                            .foregroundColor(.white.opacity(0.6))
                                            .padding(.leading, 8)
                                            .allowsHitTesting(false)
                                    }
                                }
                                .padding(.vertical, 16)
                            }
                            .background(Color.cardBackground)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(showError ? Color.red.opacity(0.8) : Color.surfaceBackground.opacity(0.8), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 28)

                    VStack(spacing: 16) {
                        Button(action: {
                            HapticManager.shared.impact(.light)
                            onComplete()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.9)
                                } else {
                                    Text(String(localized: "Continue"))
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 19)
                            .background(
                                Group {
                                    if canProceed {
                                        LinearGradient(
                                            colors: [Color.primaryGreen, Color.accentGreen],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    } else {
                                        LinearGradient(
                                            colors: [Color.surfaceBackground, Color.surfaceBackground],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    }
                                }
                            )
                            .foregroundColor(canProceed ? .white : .secondaryText)
                            .cornerRadius(17)
                            .shadow(color: canProceed ? Color.primaryGreen.opacity(0.35) : .clear, radius: 12, x: 0, y: 4)
                        }
                        .disabled(!canProceed || isLoading)
                        .animation(.easeInOut(duration: 0.2), value: canProceed)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 26)
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity)
            }
            .scrollDisabled(!isTextFieldFocused)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
        }
        .alert(String(localized: "Error"), isPresented: $showError) {
            Button(String(localized: "OK")) {
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.warning)
            }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerView(selectedCountry: $selectedCountry)
        }
    }
}

extension OnboardingStep {
    static let defaultSteps: [OnboardingStep] = [
        OnboardingStep(
            title: "Welcome to Call Recorder",
            subtitle: "Record and transcribe your important calls",
            icon: "phone.circle.fill"
        ),
        OnboardingStep(
            title: "Smart Call Recording",
            subtitle: "AI-powered transcription with 99% accuracy",
            icon: "waveform.circle.fill"
        ),
        OnboardingStep(
            title: "Instant Summary & Insights",
            subtitle: "Get key points and action items automatically",
            icon: "sparkles"
        ),
        OnboardingStep(
            title: "Enter Your Phone Number",
            subtitle: "Select your country and enter your phone number",
            icon: "person.circle.fill"
        )
    ]
}
