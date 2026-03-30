import SwiftUI
import StoreKit

struct OnboardingVariantA: View {
    @State private var currentStep = 0
    @State private var imageScale: CGFloat = 1.0
    @State private var imageOffset: CGFloat = 0
    @State private var contentOpacity: Double = 1.0
    @State private var buttonScale: CGFloat = 1.0
    @StateObject private var viewModel = AppViewModel.shared
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    @Environment(\.requestReview) var requestReview

    private let steps = OnboardingStep.defaultSteps

    var body: some View {
        geometryContent
            .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: currentStep)
            .preferredColorScheme(.dark)
    }

    private var geometryContent: some View {
        GeometryReader { geometry in
            ZStack {
                Image(currentStep == 0 ? "onboarding1" : currentStep == 1 ? "onboarding2" : "onboarding3")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300)
                    .scaleEffect(imageScale)
                    .offset(x: imageOffset)
                    .ignoresSafeArea(edges: .all)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0), value: currentStep)

                VStack {
                    Spacer()
                    gradientOverlay
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
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

    private var gradientOverlay: some View {
        VStack(spacing: 0) {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.2),
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 150)

            Color.black.opacity(0.4)
                .frame(maxHeight: .infinity)
        }
        .overlay(
            VStack(spacing: 38) {
                VStack(spacing: 8) {
                    Text(steps[currentStep].title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                        .opacity(contentOpacity)

                    Text(variantASubtitle(for: currentStep))
                        .font(.body)
                        .foregroundColor(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                        .opacity(contentOpacity)
                }

                Button(action: nextButtonTapped) {
                    Text("Next")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.primaryGreen)
                        .foregroundColor(.black)
                        .cornerRadius(28)
                        .scaleEffect(buttonScale)
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 50),
            alignment: .bottom
        )
    }

    private func nextButtonTapped() {
        HapticManager.shared.impact(.light)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { buttonScale = 0.95 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { buttonScale = 1.0 }
            nextStep()
        }
    }

    private func nextStep() {
        if currentStep < 2 {
            withAnimation(.easeOut(duration: 0.2)) { contentOpacity = 0 }

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                imageScale = 1.1
                imageOffset = -50
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    currentStep += 1
                    imageScale = 1.0
                    imageOffset = 0
                }
                withAnimation(.easeIn(duration: 0.3).delay(0.1)) { contentOpacity = 1 }
            }
        } else {
            self.completeOnboarding()
        }
    }

    private func variantASubtitle(for step: Int) -> String {
        switch step {
        case 0: return "Record and transcribe your important\ncalls with ease"
        case 1: return "Never miss important details again.\nOur AI captures every word with precision"
        case 2: return "Save hours with automated meeting notes.\nFocus on the conversation, not note-taking"
        default: return steps[step].subtitle
        }
    }
}
