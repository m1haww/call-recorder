import SwiftUI
import StoreKit

// MARK: - Variant C: verde închis (diferit de B), widget-uri, animații
private extension Color {
    /// Verde închis pentru varianta C — distinct de primaryGreen (verde deschis) din B.
    static let variantCGreen = Color(hex: "#2E7D32")
    static let variantCGreenLight = Color(hex: "#388E3C")
}

private let variantCIntroSteps: [(title: String, subtitle: String)] = [
    ("Record calls hassle free", "Seamless call recording of all your incoming and outgoing phone calls"),
    ("Automatically record outgoing calls", "Make an outgoing call with 2 simple steps and we'll take care of the recording"),
    ("Transcribe your recorded calls", "Transcribe your calls straight after finishing a call and store them on your phone or share."),
    ("Organize your recordings", "Create lists and have full control of your recorded calls and transcriptions")
]

/// Onboarding variant C — verde închis, widget-uri ca în B, animații, fără verde deschis.
struct OnboardingVariantC: View {
    @ObservedObject private var viewModel = AppViewModel.shared

    @State private var phoneNumber = ""
    @State private var selectedCountry = Country.defaultCountry
    @State private var showCountryPicker = false
    @State private var currentStep = 0
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var widgetScale: CGFloat = 0.88
    @State private var widgetOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var buttonScale: CGFloat = 1

    private static let introCount = 4
    private static let phoneStepIndex = 4

    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            backgroundGradient

            VStack(spacing: 0) {
                if currentStep < OnboardingVariantC.phoneStepIndex {
                    introScreen
                } else {
                    phoneStepScreen
                }

                Spacer(minLength: 24)

                continueButton
                progressDots
                    .padding(.top, 20)
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
        .onChange(of: currentStep) { _ in
            runStepAnimations()
        }
        .onAppear {
            runStepAnimations()
        }
    }

    private func runStepAnimations() {
        widgetScale = 0.88
        widgetOpacity = 0
        textOpacity = 0
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            widgetScale = 1
            widgetOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.35).delay(0.15)) {
            textOpacity = 1
        }
    }

    private var backgroundGradient: some View {
        RadialGradient(
            colors: [
                Color.darkBackground,
                Color.darkBackground,
                Color.variantCGreen.opacity(0.06)
            ],
            center: UnitPoint(x: 0.5, y: 0.35),
            startRadius: 0,
            endRadius: 420
        )
        .ignoresSafeArea()
    }

    private var introScreen: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 36) {
                Spacer()
                    .frame(height: 28)

                stepWidget
                    .scaleEffect(widgetScale)
                    .opacity(widgetOpacity)

                VStack(spacing: 14) {
                    Text(variantCIntroSteps[currentStep].title)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.center)
                        .opacity(textOpacity)

                    Text(variantCIntroSteps[currentStep].subtitle)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.horizontal, 28)
                        .opacity(textOpacity)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var stepWidget: some View {
        switch currentStep {
        case 0:
            VariantC_WidgetRecord()
        case 1:
            VariantC_WidgetOutgoing()
        case 2:
            VariantC_WidgetTranscribe()
        case 3:
            VariantC_WidgetOrganize()
        default:
            EmptyView()
        }
    }

    private var continueButton: some View {
        Button(action: {
            HapticManager.shared.impact(.light)
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) { buttonScale = 0.96 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { buttonScale = 1 }
                nextStep()
            }
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
                LinearGradient(
                    colors: canProceed ? [Color.variantCGreen, Color.variantCGreenLight] : [Color.surfaceBackground, Color.surfaceBackground],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(28)
            .scaleEffect(buttonScale)
            .shadow(color: canProceed ? Color.variantCGreen.opacity(0.45) : Color.clear, radius: 14, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .disabled(!canProceed || isLoading)
        .padding(.horizontal, 28)
    }

    private var progressDots: some View {
        HStack(spacing: 10) {
            ForEach(0..<(OnboardingVariantC.introCount + 1), id: \.self) { index in
                Circle()
                    .fill(index <= currentStep ? Color.variantCGreen : Color.surfaceBackground.opacity(0.7))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == min(currentStep, OnboardingVariantC.phoneStepIndex) ? 1.2 : 1)
                    .animation(.spring(response: 0.35, dampingFraction: 0.6), value: currentStep)
            }
        }
    }

    private var phoneStepScreen: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                Spacer()
                    .frame(height: 32)

                ZStack {
                    Circle()
                        .fill(Color.variantCGreen.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .blur(radius: 20)
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.variantCGreen, Color.variantCGreenLight],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 10) {
                    Text("You're almost there")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.variantCGreen)
                    Text("Enter Your Phone Number")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.center)
                    Text("Select your country and enter your phone number to get started.")
                        .font(.system(size: 15))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                VStack(spacing: 16) {
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
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
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
                            .padding(.leading, 20)
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
                .padding(.horizontal, 28)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var canProceed: Bool {
        if currentStep < OnboardingVariantC.phoneStepIndex { return true }
        return isValidPhoneNumber(phoneNumber)
    }

    private func nextStep() {
        isTextFieldFocused = false
        if currentStep < OnboardingVariantC.phoneStepIndex {
            withAnimation(.easeInOut(duration: 0.3)) { currentStep += 1 }
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

// MARK: - Widget-uri varianta C (verde închis, stil ca B dar culoare diferită)

private struct VariantC_WidgetRecord: View {
    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(0..<3, id: \.self) { _ in
                    HStack(spacing: 8) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.primaryText)
                        VStack(alignment: .leading, spacing: 4) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.surfaceBackground)
                                .frame(height: 7)
                                .frame(maxWidth: .infinity)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.variantCGreen)
                                .frame(width: 36, height: 4)
                        }
                        Spacer(minLength: 4)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.variantCGreen.opacity(0.5), lineWidth: 1.5)
            )

            VStack(spacing: 14) {
                Circle()
                    .fill(Color.variantCGreen)
                    .frame(width: 48, height: 48)
                    .overlay(Image(systemName: "phone.fill").font(.system(size: 20)).foregroundColor(.white))
                    .shadow(color: Color.variantCGreen.opacity(0.5), radius: 8)
                Circle()
                    .fill(Color.variantCGreen.opacity(0.8))
                    .frame(width: 48, height: 48)
                    .overlay(Image(systemName: "mic.fill").font(.system(size: 20)).foregroundColor(.white))
            }
        }
        .padding(.horizontal, 24)
        .frame(height: 180)
    }
}

private struct VariantC_WidgetOutgoing: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(Color.surfaceBackground)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
            }
            .padding(12)
            .background(Color.cardBackground)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.surfaceBackground, lineWidth: 1))

            VStack(spacing: 12) {
                Text("00:23")
                    .font(.system(size: 18, weight: .medium, design: .monospaced))
                    .foregroundColor(.primaryText)
                HStack(spacing: 2) {
                    ForEach(0..<16, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.variantCGreen)
                            .frame(width: 4, height: CGFloat([10, 16, 12, 20, 14, 18, 10, 22, 14, 12, 18, 14, 20, 10, 16, 12][i]))
                    }
                }
                .frame(height: 22)
                ZStack {
                    Circle()
                        .stroke(Color.primaryText.opacity(0.3), lineWidth: 2)
                        .frame(width: 44, height: 44)
                    Circle()
                        .fill(Color.variantCGreen)
                        .frame(width: 36, height: 36)
                    Image(systemName: "stop.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(Color.cardBackground)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.variantCGreen.opacity(0.5), lineWidth: 1.5))
        }
        .padding(.horizontal, 24)
        .frame(height: 200)
    }
}

private struct VariantC_WidgetTranscribe: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Spacer(); bubble(lines: [50, 32], isUser: false) }
            HStack { bubble(lines: [70, 45, 28], isUser: true); Spacer() }
            HStack { Spacer(); bubble(lines: [55, 38], isUser: false) }
            HStack { bubble(lines: [45, 65], isUser: true); Spacer() }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.variantCGreen.opacity(0.5), lineWidth: 1.5))
        .padding(.horizontal, 28)
        .frame(height: 200)
    }

    private func bubble(lines: [CGFloat], isUser: Bool) -> some View {
        VStack(alignment: isUser ? .leading : .trailing, spacing: 4) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, w in
                RoundedRectangle(cornerRadius: 2)
                    .fill(isUser ? Color.white.opacity(0.9) : Color.secondaryText)
                    .frame(width: w, height: 5)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isUser ? Color.variantCGreen : Color.surfaceBackground)
        )
    }
}

private struct VariantC_WidgetOrganize: View {
    var body: some View {
        VStack(spacing: 14) {
            section(count: 3)
            section(count: 2)
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.variantCGreen.opacity(0.5), lineWidth: 1.5))
        .padding(.horizontal, 28)
        .frame(height: 200)
    }

    private func section(count: Int) -> some View {
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
                            .fill(Color.variantCGreen)
                            .frame(width: 28, height: 3)
                    }
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.variantCGreen)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.surfaceBackground.opacity(0.5))
                .cornerRadius(10)
            }
        }
    }
}
