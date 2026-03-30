import SwiftUI
import StoreKit

private let variantBIntroSteps: [(title: String, subtitle: String)] = [
    ("Record calls hassle free", "Seamless call recording of all your incoming and outgoing phone calls"),
    ("Automatically record outgoing calls", "Make an outgoing call with 2 simple steps and we'll take care of the recording"),
    ("Transcribe your recorded calls", "Transcribe your calls straight after finishing a call and store them on your phone or share."),
    ("Organize your recordings", "Create lists and have full control of your recorded calls and transcriptions")
]

struct OnboardingVariantB: View {
    @StateObject private var viewModel = AppViewModel.shared
    @StateObject private var subscriptionService = SubscriptionService.shared

    @State private var currentStep = 0
    @Environment(\.requestReview) var requestReview

    private static let introCount = 4

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
                introContent

                Spacer(minLength: 24)

                continueButton
                    .padding(.bottom, 12)
                
                pageIndicators
                    .padding(.bottom, 22)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var introContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 36) {
                stepIllustration
                    .frame(height: 400)
                    .padding(.top, 5)
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
            Text("Continue")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                LinearGradient(
                    colors: [Color.primaryGreen, Color.accentGreen],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.black)
            .cornerRadius(30)
            .shadow(color: Color.primaryGreen.opacity(0.45), radius: 16, x: 0, y: 6)
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
    }

    private var pageIndicators: some View {
        HStack(spacing: 10) {
            ForEach(0..<OnboardingVariantB.introCount, id: \.self) { index in
                if index == currentStep {
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

    private func nextStep() {
        if currentStep < OnboardingVariantB.introCount - 1 {
            withAnimation(.easeInOut(duration: 0.25)) { currentStep += 1 }
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

private struct VariantB_RecordCallsIllustration: View {
    var body: some View {
        ZStack {
            VariantB_PhoneFrame(size: 240) {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(0..<3, id: \.self) { _ in
                        HStack(spacing: 10) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.primaryText)
                            VStack(alignment: .leading, spacing: 5) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.surfaceBackground)
                                    .frame(height: 9)
                                    .frame(maxWidth: .infinity)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.primaryGreen)
                                    .frame(width: 52, height: 5)
                                    .shadow(color: Color.primaryGreen.opacity(0.4), radius: 2)
                            }
                            Spacer()
                            Text("0")
                                .font(.caption)
                                .foregroundColor(.secondaryText)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Capsule().fill(Color.surfaceBackground))
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
            .offset(x: -34, y: -24)
            .scaleEffect(1.0)

            VariantB_PhoneFrame(size: 240) {
                HStack(spacing: 32) {
                    ZStack {
                        Circle()
                            .fill(Color.primaryGreen.opacity(0.35))
                            .frame(width: 64, height: 64)
                            .blur(radius: 8)
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.primaryGreen, Color.accentGreen],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                            .overlay(
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.black)
                            )
                            .shadow(color: Color.primaryGreen.opacity(0.5), radius: 6)
                    }
                    ZStack {
                        Circle()
                            .fill(Color.primaryGreen.opacity(0.3))
                            .frame(width: 64, height: 64)
                            .blur(radius: 8)
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.primaryGreen.opacity(0.9), Color.accentGreen.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                            .overlay(
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.black)
                            )
                            .shadow(color: Color.primaryGreen.opacity(0.4), radius: 6)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .offset(x: 38, y: 20)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct VariantB_OutgoingCallsIllustration: View {
    var body: some View {
        ZStack {
            VariantB_PhoneFrame(size: 240) {
                VStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: 8) {
                            ForEach(0..<3, id: \.self) { col in
                                Circle()
                                    .fill(Color.surfaceBackground)
                                    .frame(width: 26, height: 26)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .offset(x: -38, y: -20)
            .scaleEffect(1.0)

            VariantB_PhoneFrame(size: 240) {
                VStack(spacing: 14) {
                    Text("00:23")
                        .font(.system(size: 24, weight: .medium, design: .monospaced))
                        .foregroundColor(.primaryText)
                    HStack(spacing: 4) {
                        ForEach(0..<20, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(Color.primaryGreen)
                                .frame(width: 4, height: CGFloat([8, 14, 10, 18, 12, 16, 8, 20, 14, 10, 16, 12, 18, 8, 14, 10, 16, 12, 18, 14][i]) * 1.2)
                        }
                    }
                    .frame(height: 28)
                    .shadow(color: Color.primaryGreen.opacity(0.4), radius: 4)
                    ZStack {
                        Circle()
                            .fill(Color.primaryGreen.opacity(0.25))
                            .frame(width: 64, height: 64)
                            .blur(radius: 6)
                        Circle()
                            .stroke(Color.primaryText.opacity(0.4), lineWidth: 2.5)
                            .frame(width: 58, height: 58)
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.primaryGreen, Color.accentGreen],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .shadow(color: Color.primaryGreen.opacity(0.5), radius: 6)
                        Image(systemName: "stop.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                    }
                    HStack {
                        Circle()
                            .fill(Color.surfaceBackground)
                            .frame(width: 34, height: 34)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.secondaryText)
                            )
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .offset(x: 34, y: 16)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct VariantB_TranscribeIllustration: View {
    var body: some View {
        VariantB_PhoneFrame(size: 268) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Spacer()
                    bubble(lines: [72, 48], isUser: false)
                }
                HStack {
                    bubble(lines: [96, 60, 36], isUser: true)
                    Spacer()
                }
                HStack {
                    Spacer()
                    bubble(lines: [84, 54], isUser: false)
                }
                HStack {
                    bubble(lines: [60, 108], isUser: true)
                    Spacer()
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func bubble(lines: [CGFloat], isUser: Bool) -> some View {
        VStack(alignment: isUser ? .leading : .trailing, spacing: 5) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, w in
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(isUser ? Color.black.opacity(0.75) : Color.secondaryText)
                    .frame(width: w, height: 6)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
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

private struct VariantB_OrganizeIllustration: View {
    var body: some View {
        VariantB_PhoneFrame(size: 268) {
            VStack(spacing: 14) {
                listSection(count: 3)
                listSection(count: 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
    }

    private func listSection(count: Int) -> some View {
        VStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { _ in
                HStack(spacing: 10) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.primaryText)
                    VStack(alignment: .leading, spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.surfaceBackground)
                            .frame(height: 7)
                            .frame(maxWidth: .infinity)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.primaryGreen.opacity(0.8))
                            .frame(width: 40, height: 4)
                    }
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.primaryText.opacity(0.8))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.surfaceBackground.opacity(0.6))
                .cornerRadius(10)
            }
        }
        .padding(14)
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
