import SwiftUI
import StoreKit

// MARK: - Variant B step content (4 intro screens from reference + phone)
private let variantBIntroSteps: [(title: String, subtitle: String)] = [
    ("Record calls hassle free", "Seamless call recording of all your incoming and outgoing phone calls"),
    ("Automatically record outgoing calls", "Make an outgoing call with 2 simple steps and we'll take care of the recording"),
    ("Transcribe your recorded calls", "Transcribe your calls straight after finishing a call and store them on your phone or share."),
    ("Organize your recordings", "Create lists and have full control of your recorded calls and transcriptions")
]

/// Onboarding variant B — premium design: phone mockups, soft glow, luxury feel to drive subscription intent.
struct OnboardingVariantB: View {
    @ObservedObject private var viewModel = AppViewModel.shared

    @State private var phoneNumber = ""
    @State private var selectedCountry = Country.defaultCountry
    @State private var showCountryPicker = false
    @State private var currentStep = 0
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @FocusState private var isTextFieldFocused: Bool

    private static let introCount = 4
    private static let phoneStepIndex = 4

    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            RadialGradient(
                colors: [
                    Color.darkBackground,
                    Color.darkBackground,
                    Color.primaryGreen.opacity(0.06)
                ],
                center: UnitPoint(x: 0.5, y: 0.85),
                startRadius: 80,
                endRadius: 420
            )
            .ignoresSafeArea()
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color.primaryGreen.opacity(0.12), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 200)
                .blur(radius: 60)
                .offset(y: 120)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if currentStep < OnboardingVariantB.phoneStepIndex {
                    introContent
                } else {
                    phoneStepContent
                }

                Spacer(minLength: 24)

                continueButton
                pageIndicators
                    .padding(.bottom, 44)
            }
        }
        .onTapGesture { isTextFieldFocused = false }
        .alert("Error", isPresented: $showError) {
            Button("OK") { HapticManager.shared.notification(.warning) }
        } message: { Text(errorMessage) }
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerView(selectedCountry: $selectedCountry)
        }
        .preferredColorScheme(.dark)
    }

    private var introContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 36) {
                stepIllustration
                    .frame(height: 300)
                    .padding(.top, 20)
                    .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 12)

                VStack(spacing: 14) {
                    Text(variantBIntroSteps[currentStep].title)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)

                    Text(variantBIntroSteps[currentStep].subtitle)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondaryText.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)

                    if currentStep == 3 {
                        Text("Everything you need in one place.")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primaryGreen.opacity(0.95))
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var stepIllustration: some View {
        switch currentStep {
        case 0:
            VariantB_RecordCallsIllustration()
        case 1:
            VariantB_OutgoingCallsIllustration()
        case 2:
            VariantB_TranscribeIllustration()
        case 3:
            VariantB_OrganizeIllustration()
        default:
            EmptyView()
        }
    }

    private var continueButton: some View {
        Button(action: {
            HapticManager.shared.impact(.light)
            nextStep()
        }) {
            Group {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .scaleEffect(0.8)
                } else {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
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
            .foregroundColor(.black)
            .cornerRadius(30)
            .shadow(color: canProceed ? Color.primaryGreen.opacity(0.45) : Color.clear, radius: 16, x: 0, y: 6)
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(!canProceed || isLoading)
        .padding(.horizontal, 24)
    }

    private var pageIndicators: some View {
        HStack(spacing: 10) {
            ForEach(0..<(OnboardingVariantB.introCount + 1), id: \.self) { index in
                if index == min(currentStep, OnboardingVariantB.introCount) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.primaryGreen)
                        .frame(width: 24, height: 6)
                        .shadow(color: Color.primaryGreen.opacity(0.5), radius: 4)
                } else {
                    Circle()
                        .fill(Color.surfaceBackground.opacity(0.8))
                        .frame(width: 6, height: 6)
                }
            }
        }
        .padding(.top, 20)
    }

    private var phoneStepContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .fill(Color.primaryGreen.opacity(0.2))
                        .frame(width: 88, height: 88)
                        .blur(radius: 20)
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.primaryGreen, Color.accentGreen],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 10) {
                    Text("You're almost there")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primaryGreen)
                    Text("Enter Your Phone Number")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.center)
                    Text("Select your country and enter your phone number to get started")
                        .font(.system(size: 15))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                VStack(spacing: 18) {
                    Button(action: {
                        HapticManager.shared.selection()
                        showCountryPicker = true
                    }) {
                        HStack {
                            Text("\(selectedCountry.flag) \(selectedCountry.name)")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.primaryText)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondaryText)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(Color.cardBackground)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.surfaceBackground, lineWidth: 1)
                        )
                    }

                    HStack(spacing: 0) {
                        Text(selectedCountry.dialCode)
                            .font(.system(size: 17))
                            .foregroundColor(.secondaryText)
                            .padding(.leading, 18)
                        TextField("Phone number", text: $phoneNumber)
                            .font(.system(size: 17))
                            .foregroundColor(.primaryText)
                            .keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
                            .padding()
                            .focused($isTextFieldFocused)
                    }
                    .background(Color.cardBackground)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(showError ? Color.red : Color.surfaceBackground, lineWidth: 1)
                    )

                    Text("Enter your phone number without the country code")
                        .font(.system(size: 13))
                        .foregroundColor(.secondaryText.opacity(0.9))
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
            .padding(.top, 36)
        }
        .frame(maxWidth: .infinity)
    }

    private var canProceed: Bool {
        if currentStep < OnboardingVariantB.phoneStepIndex { return true }
        return isValidPhoneNumber(phoneNumber)
    }

    private func nextStep() {
        isTextFieldFocused = false
        if currentStep < OnboardingVariantB.phoneStepIndex {
            withAnimation(.easeInOut(duration: 0.25)) { currentStep += 1 }
        } else {
            if isValidPhoneNumber(phoneNumber) {
                registerUser()
            } else {
                HapticManager.shared.notification(.error)
                showError = true
                errorMessage = "Please enter a valid phone number for \(selectedCountry.name)"
            }
        }
    }

    private func registerUser() {
        let fullPhoneNumber = selectedCountry.dialCode + phoneNumber
        isLoading = true
        UserService.shared.registerUser(phoneNumber: fullPhoneNumber, countryCode: selectedCountry.code) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let userId):
                    self.viewModel.saveUserId(userId)
                    completeOnboarding()
                    viewModel.showPaywall = true
                case .failure(let error):
                    HapticManager.shared.notification(.error)
                    self.showError = true
                    self.errorMessage = "Registration failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private func completeOnboarding() {
        viewModel.completeOnboarding()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func isValidPhoneNumber(_ number: String) -> Bool {
        let cleaned = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return cleaned.count >= 7 && cleaned.count <= 15 && !cleaned.isEmpty
    }
}

// MARK: - Phone frame (shared) — premium depth and border
private struct VariantB_PhoneFrame<Content: View>: View {
    let content: Content
    var size: CGFloat = 140

    init(size: CGFloat = 140, @ViewBuilder content: () -> Content) {
        self.size = size
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [Color.cardBackground, Color.cardBackground.opacity(0.95)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.12), Color.surfaceBackground],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 8)
                .frame(width: size * 0.52, height: size)

            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.darkBackground)
                    .frame(width: 40, height: 7)
                    .padding(.top, 12)
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(12)
                    .padding(.top, 6)
            }
            .frame(width: size * 0.52, height: size)
        }
    }
}

// MARK: - Screen 0: Record calls hassle free — two phones, call logs + action buttons
private struct VariantB_RecordCallsIllustration: View {
    var body: some View {
        ZStack {
            VariantB_PhoneFrame(size: 200) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(0..<3, id: \.self) { _ in
                        HStack(spacing: 8) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.primaryText)
                            VStack(alignment: .leading, spacing: 4) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.surfaceBackground)
                                    .frame(height: 8)
                                    .frame(maxWidth: .infinity)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.primaryGreen)
                                    .frame(width: 44, height: 4)
                                    .shadow(color: Color.primaryGreen.opacity(0.4), radius: 2)
                            }
                            Spacer()
                            Text("0")
                                .font(.caption2)
                                .foregroundColor(.secondaryText)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.surfaceBackground))
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
            .offset(x: -28, y: -20)
            .scaleEffect(0.9)

            VariantB_PhoneFrame(size: 200) {
                HStack(spacing: 28) {
                    ZStack {
                        Circle()
                            .fill(Color.primaryGreen.opacity(0.35))
                            .frame(width: 56, height: 56)
                            .blur(radius: 8)
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.primaryGreen, Color.accentGreen],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                            .overlay(
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                            )
                            .shadow(color: Color.primaryGreen.opacity(0.5), radius: 6)
                    }
                    ZStack {
                        Circle()
                            .fill(Color.primaryGreen.opacity(0.3))
                            .frame(width: 56, height: 56)
                            .blur(radius: 8)
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.primaryGreen.opacity(0.9), Color.accentGreen.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                            .overlay(
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                            )
                            .shadow(color: Color.primaryGreen.opacity(0.4), radius: 6)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .offset(x: 32, y: 16)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Screen 1: Automatically record outgoing calls — dial pad + recording UI
private struct VariantB_OutgoingCallsIllustration: View {
    var body: some View {
        ZStack {
            VariantB_PhoneFrame(size: 200) {
                VStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: 6) {
                            ForEach(0..<3, id: \.self) { col in
                                Circle()
                                    .fill(Color.surfaceBackground)
                                    .frame(width: 22, height: 22)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .offset(x: -32, y: -16)
            .scaleEffect(0.88)

            VariantB_PhoneFrame(size: 200) {
                VStack(spacing: 12) {
                    Text("00:23")
                        .font(.system(size: 20, weight: .medium, design: .monospaced))
                        .foregroundColor(.primaryText)
                    HStack(spacing: 3) {
                        ForEach(0..<20, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(Color.primaryGreen)
                                .frame(width: 3, height: CGFloat([8, 14, 10, 18, 12, 16, 8, 20, 14, 10, 16, 12, 18, 8, 14, 10, 16, 12, 18, 14][i]))
                        }
                    }
                    .frame(height: 24)
                    .shadow(color: Color.primaryGreen.opacity(0.4), radius: 4)
                    ZStack {
                        Circle()
                            .fill(Color.primaryGreen.opacity(0.25))
                            .frame(width: 56, height: 56)
                            .blur(radius: 6)
                        Circle()
                            .stroke(Color.primaryText.opacity(0.4), lineWidth: 2.5)
                            .frame(width: 50, height: 50)
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.primaryGreen, Color.accentGreen],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 42, height: 42)
                            .shadow(color: Color.primaryGreen.opacity(0.5), radius: 6)
                        Image(systemName: "stop.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                    HStack {
                        Circle()
                            .fill(Color.surfaceBackground)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondaryText)
                            )
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .offset(x: 28, y: 12)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Screen 2: Transcribe — chat bubbles
private struct VariantB_TranscribeIllustration: View {
    var body: some View {
        VariantB_PhoneFrame(size: 220) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Spacer()
                    bubble(lines: [60, 40], isUser: false)
                }
                HStack {
                    bubble(lines: [80, 50, 30], isUser: true)
                    Spacer()
                }
                HStack {
                    Spacer()
                    bubble(lines: [70, 45], isUser: false)
                }
                HStack {
                    bubble(lines: [50, 90], isUser: true)
                    Spacer()
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func bubble(lines: [CGFloat], isUser: Bool) -> some View {
        VStack(alignment: isUser ? .leading : .trailing, spacing: 4) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, w in
                RoundedRectangle(cornerRadius: 2)
                    .fill(isUser ? Color.black.opacity(0.75) : Color.secondaryText)
                    .frame(width: w, height: 5)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isUser ? Color.primaryGreen : Color.cardBackground)
                .shadow(color: isUser ? Color.primaryGreen.opacity(0.35) : Color.clear, radius: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isUser ? Color.primaryGreen.opacity(0.5) : Color.clear, lineWidth: 1)
                )
        )
    }
}

// MARK: - Screen 3: Organize — lists with green borders
private struct VariantB_OrganizeIllustration: View {
    var body: some View {
        VariantB_PhoneFrame(size: 220) {
            VStack(spacing: 12) {
                listSection(count: 3)
                listSection(count: 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
    }

    private func listSection(count: Int) -> some View {
        VStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { _ in
                HStack(spacing: 8) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.primaryText)
                    VStack(alignment: .leading, spacing: 3) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.surfaceBackground)
                            .frame(height: 6)
                            .frame(maxWidth: .infinity)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.primaryGreen.opacity(0.8))
                            .frame(width: 32, height: 3)
                    }
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.primaryText.opacity(0.8))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.surfaceBackground.opacity(0.6))
                .cornerRadius(8)
            }
        }
        .padding(12)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(
                        colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: Color.primaryGreen.opacity(0.2), radius: 8)
    }
}
