import SwiftUI
import StoreKit

private func variantDStep(for index: Int) -> (imageName: String, title: String, subtitle: String) {
    switch index {
    case 0:
        return (
            "onb1",
            String(localized: "Never miss important details"),
            String(localized: "Important conversations are easy to forget.")
        )
    case 1:
        return (
            "onb2",
            String(localized: "Record every call instantly"),
            String(localized: "Capture conversations with one tap.")
        )
    case 2:
        return (
            "onb3",
            String(localized: "Turn calls into text"),
            String(localized: "Get instant, searchable transcripts.")
        )
    default:
        return (
            "onb4",
            String(localized: "All your calls in one place"),
            String(localized: "Access, organize, and replay anytime.")
        )
    }
}

struct OnboardingVariantD: View {
    @StateObject private var viewModel = AppViewModel.shared
    @StateObject private var subscriptionService = SubscriptionService.shared

    @State private var currentStep = 0
    @State private var textOpacity: Double = 0
    @State private var buttonScale: CGFloat = 1

    @Environment(\.requestReview) var requestReview

    private static let introCount = 4

    private var step: (imageName: String, title: String, subtitle: String) {
        variantDStep(for: currentStep)
    }

    var body: some View {
        ZStack {
            Image(step.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .scaleEffect(0.93, anchor: .top)
                .padding(.top, 6)
                .clipped()
                .ignoresSafeArea()

            bottomGradient
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 0)

                titleBlock
                    .padding(.bottom, 52)

                HStack(spacing: 20) {
                    stepProgress
                    Spacer()
                    nextCircleButton
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 68)
            .padding(.top, 12)
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .onChange(of: currentStep) { _ in
            runStepAnimations()
        }
        .onAppear {
            runStepAnimations()
        }
    }

    private var bottomGradient: some View {
        ZStack {
            VStack {
                Spacer()
                LinearGradient(
                    colors: [
                        Color.darkBackground,
                        Color.darkBackground,
                        Color.darkBackground,
                        Color.darkBackground,
                        Color.darkBackground.opacity(0.9),
                        Color.clear
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: UIScreen.main.bounds.height * 0.6)
                .allowsHitTesting(false)
            }
            
            VStack {
                Spacer()
                
                LinearGradient(
                    colors: [
                        Color(red: 74 / 255, green: 229 / 255, blue: 75 / 255).opacity(0.1),
                        Color.clear,
                        Color.clear
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: UIScreen.main.bounds.height)
            }
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(step.title)
                .font(.system(size: 38, weight: .bold, design: .default))
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.leading)

            Text(step.subtitle)
                .font(.system(size: 18, weight: .regular, design: .default))
                .foregroundColor(.primaryText.opacity(0.92))
                .multilineTextAlignment(.leading)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(textOpacity)
    }

    private var stepProgress: some View {
        HStack(spacing: 0) {
            ForEach(0..<Self.introCount, id: \.self) { index in
                progressNode(index: index)
                if index < Self.introCount - 1 {
                    progressConnector(afterIndex: index)
                }
            }
        }
    }

    private func progressNode(index: Int) -> some View {
        ZStack {
            if index <= currentStep {
                Circle()
                    .fill(Color.primaryGreen)
                    .frame(width: 26, height: 26)
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
            } else {
                Circle()
                    .strokeBorder(Color.primaryText.opacity(0.85), lineWidth: 2)
                    .frame(width: 26, height: 26)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.72), value: currentStep)
    }

    private func progressConnector(afterIndex index: Int) -> some View {
        Rectangle()
            .fill(index < currentStep ? Color.primaryGreen : Color.primaryText.opacity(0.28))
            .frame(height: 2)
            .frame(width: 20)
            .padding(.horizontal, 2)
            .animation(.easeInOut(duration: 0.25), value: currentStep)
    }

    private var nextCircleButton: some View {
        Button(action: advance) {
            Image(systemName: "arrow.right")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
                .frame(width: 56, height: 56)
                .background(Circle().fill(Color.primaryGreen))
                .scaleEffect(buttonScale)
        }
        .buttonStyle(.plain)
    }

    private func advance() {
        HapticManager.shared.impact(.light)
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) { buttonScale = 0.94 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) { buttonScale = 1 }
            nextStep()
        }
    }

    private func runStepAnimations() {
        textOpacity = 0
        withAnimation(.easeOut(duration: 0.38).delay(0.06)) {
            textOpacity = 1
        }
    }

    private func nextStep() {
        if currentStep < Self.introCount - 1 {
            withAnimation(.easeInOut(duration: 0.28)) { currentStep += 1 }
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
