import SwiftUI
import StoreKit

private extension Color {
    static let variantCGreenDark = Color.primaryGreen.opacity(0.25)
}

struct OnboardingVariantC: View {
    @StateObject private var viewModel = AppViewModel.shared
    @StateObject private var subscriptionService = SubscriptionService.shared

    @State private var currentStep = 0
    @State private var selectedOptionIndex: Int = 0
    @State private var widgetScale: CGFloat = 0.88
    @State private var widgetOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var buttonScale: CGFloat = 1
    
    @Environment(\.requestReview) var requestReview

    private static let introCount = 3

    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            backgroundGradient

            VStack(spacing: 0) {
                introScreen

                Spacer(minLength: 24)

                continueButton
                progressDots
                    .padding(.vertical, 22)
            }
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
                Color.primaryGreen.opacity(0.06)
            ],
            center: UnitPoint(x: 0.5, y: 0.35),
            startRadius: 0,
            endRadius: 420
        )
        .ignoresSafeArea()
    }

    private var introScreen: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: currentStep == 0 ? 28 : 36) {
                Spacer()
                    .frame(height: 28)

                if currentStep == 0 {
                    step1Content
                } else {
                    stepTitleOnly
                    stepWidget
                        .scaleEffect(widgetScale)
                        .opacity(widgetOpacity)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var step1Content: some View {
        VStack(spacing: 38) {
            Text(String(localized: "What do you need today?"))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)
                .opacity(textOpacity)
                .padding(.horizontal, 24)

            VStack(spacing: 16) {
                optionCard(
                    icon: "phone.arrow.up.right",
                    title: String(localized: "Record calls & keep evidence"),
                    isSelected: selectedOptionIndex == 0
                ) {
                    HapticManager.shared.selection()
                    withAnimation(.easeInOut(duration: 0.2)) { selectedOptionIndex = 0 }
                }
                optionCard(
                    icon: "checkmark.shield.fill",
                    title: String(localized: "Stay private on public Wi-Fi (VPN)"),
                    isSelected: selectedOptionIndex == 1
                ) {
                    HapticManager.shared.selection()
                    withAnimation(.easeInOut(duration: 0.2)) { selectedOptionIndex = 1 }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func optionCard(icon: String, title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.variantCGreenDark)
                        .frame(width: 42, height: 42)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(.primaryGreen)
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(18)
            .background(Color.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.primaryGreen : Color.surfaceBackground.opacity(0.8),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var stepTitleOnly: some View {
        Text(currentStep == 1 ? String(localized: "Record calls in one tap") : String(localized: "Auto-save, transcripts & summaries"))
            .font(.system(size: 26, weight: .bold, design: .rounded))
            .foregroundColor(.primaryText)
            .multilineTextAlignment(.center)
            .opacity(textOpacity)
            .padding(.horizontal, 28)
    }

    @ViewBuilder
    private var stepWidget: some View {
        switch currentStep {
        case 1:
            VariantC_RecordOneTapView()
        case 2:
            VariantC_AutoSaveView()
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
            Text(currentStep == 0 ? String(localized: "Continue") : String(localized: "Next"))
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(buttonBackground)
                .foregroundColor(buttonForeground)
                .cornerRadius(28)
                .scaleEffect(buttonScale)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 28)
    }

    private var buttonBackground: some View {
        LinearGradient(
            colors: [Color.primaryGreen, Color.accentGreen],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var buttonForeground: Color {
        .black
    }

    private var progressDots: some View {
        HStack(spacing: 10) {
            ForEach(0..<OnboardingVariantC.introCount, id: \.self) { index in
                Circle()
                    .fill(index <= currentStep ? Color.primaryGreen : Color.surfaceBackground.opacity(0.7))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == currentStep ? 1.2 : 1)
                    .animation(.spring(response: 0.35, dampingFraction: 0.6), value: currentStep)
            }
        }
    }

    private func nextStep() {
        if currentStep < OnboardingVariantC.introCount - 1 {
            withAnimation(.easeInOut(duration: 0.3)) { currentStep += 1 }
        } else {
            completeOnboarding()
        }
    }

    private func completeOnboarding() {
        subscriptionService.showPaywall = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            requestReview()
            withAnimation {
                viewModel.completeOnboarding()
            }
        }
    }
}

private struct VariantC_RecordOneTapView: View {
    var body: some View {
        ZStack {
            iphone

            callButtonOverlay
        }
        .frame(height: 380)
        .padding(.horizontal, 24)
    }

    private var iphone: some View {
        Image("iphone")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 280, maxHeight: 380)
            .shadow(color: Color.primaryGreen.opacity(0.2), radius: 24, x: 0, y: 12)
    }

    private var callButtonOverlay: some View {
        ZStack {
            Circle()
                .stroke(Color.primaryGreen.opacity(0.6), lineWidth: 6)
                .frame(width: 88, height: 88)
            Circle()
                .stroke(Color.accentGreen.opacity(0.8), lineWidth: 5)
                .frame(width: 72, height: 72)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.primaryGreen, Color.accentGreen],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 58, height: 58)
                .overlay(
                    Image(systemName: "phone.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(-45))
                )
        }
        .offset(y: 8)
    }
}

private struct VariantC_AutoSaveView: View {
    var body: some View {
        ZStack(alignment: .top) {
            iphone

            folderAndDocumentOverlay
        }
        .frame(height: 380)
        .padding(.horizontal, 24)
    }

    private var iphone: some View {
        Image("iphone")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 280, maxHeight: 380)
            .shadow(color: Color.primaryGreen.opacity(0.2), radius: 24, x: 0, y: 12)
    }

    private var folderAndDocumentOverlay: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 120)
            HStack {
                Spacer()
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: -4) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.primaryGreen.opacity(0.3))
                        .frame(width: 72, height: 56)
                        .overlay(
                            Image(systemName: "folder.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.primaryGreen)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    documentWithCheckmarks
                        .offset(x: 12, y: -8)
                }
                Spacer()
            }
            Spacer()
        }
        .frame(maxWidth: 200, maxHeight: 320)
    }

    private var documentWithCheckmarks: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.secondaryText.opacity(0.4))
                .frame(width: 100, height: 8)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.primaryGreen)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.secondaryText.opacity(0.4))
                        .frame(width: 60, height: 6)
                }
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.primaryGreen)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.secondaryText.opacity(0.4))
                        .frame(width: 48, height: 6)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primaryText)
        )
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}
