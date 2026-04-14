import SwiftUI
import StoreKit

struct OnboardingKoreaVariant: View {
    @State private var currentStep = 0
    @State private var showPaywallStep = false
    @State private var heroScale: CGFloat = 1.0
    @State private var contentOpacity: Double = 1.0
    @State private var buttonScale: CGFloat = 1.0

    @StateObject private var viewModel = AppViewModel.shared
    @StateObject private var subscriptionService = SubscriptionService.shared

    private static let steps: [(title: String, subtitle: String)] = [
        (
            "통화 내용을 즉시 녹음하세요",
            "탭. 녹화. 끝."
        ),
        (
            "세세한 부분 하나도 놓치지 마세요",
            "선명한 음질\n즉시 재생\n스마트한 정리"
        ),
        (
            "지금\n녹화\n시작하기",
            "몇 초 만에 프리미엄 기능\n을 이용하세요."
        )
    ]

    private static let introStepCount = 3

    var body: some View {
        Group {
            if showPaywallStep {
                KoreaOnboardingPaywallView(
                    onPurchaseSuccess: finalizeKoreaOnboarding
                )
            } else {
                GeometryReader { geometry in
                    let maxHeroWidth = min(geometry.size.width - 48, 340)

                    ZStack {
                        Color.darkBackground
                            .ignoresSafeArea()
                        
                        LinearGradient(
                            stops: [
                                .init(color: Color.primaryGreen.opacity(0.01), location: 0.74),
                                .init(color: Color.primaryGreen.opacity(0.06), location: 0.9),
                                .init(color: Color.primaryGreen.opacity(0.1), location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()

                        VStack(spacing: 0) {
                            HStack(alignment: .top, spacing: 0) {
                                heroArea(maxWidth: maxHeroWidth)
                                Spacer(minLength: 0)
                            }
                            .padding(.leading, 28)
                            .padding(.trailing, 12)

                            Spacer(minLength: 16)
                        }
                        .padding(.top, currentStep != 0 ? 28 : -28)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                        VStack {
                            Spacer()
                            bottomPanel
                        }
                        .ignoresSafeArea(edges: .bottom)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private static let heroAssets = ["korea-1", "korea-2", "korea-3"]

    @ViewBuilder
    private func heroArea(maxWidth: CGFloat) -> some View {
        Image(Self.heroAssets[min(currentStep, Self.heroAssets.count - 1)])
            .resizable()
            .scaledToFit()
            .frame(maxWidth: maxWidth, alignment: .leading)
            .overlay(alignment: .bottom) {
                if currentStep == 0 {
                    LinearGradient(
                        stops: [
                            .init(color: Color.darkBackground, location: 0),
                            .init(color: Color.darkBackground, location: 0.5),
                            .init(color: Color.darkBackground.opacity(0), location: 1)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(width: maxWidth, height: 120)
                    .allowsHitTesting(false)
                    .transaction { $0.animation = nil }
                }
            }
            .scaleEffect(heroScale)
            .animation(.spring(response: 0.55, dampingFraction: 0.82), value: heroScale)
    }

    private var bottomPanel: some View {
        VStack(alignment: .leading, spacing: 26) {
            VStack(alignment: .leading, spacing: 14) {
                Text(Self.steps[min(currentStep, Self.steps.count - 1)].title)
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.primaryGreen)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(contentOpacity)

                Text(Self.steps[min(currentStep, Self.steps.count - 1)].subtitle)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.white.opacity(0.92))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(contentOpacity)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 28)

            Button(action: primaryButtonTapped) {
                Text(currentStep == 0 ? "시작하기" : "다음")
                    .font(.system(size: 19, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.primaryGreen, lineWidth: 2)
                    )
                    .background(Color.darkBackground)
                    .cornerRadius(28)
                    .scaleEffect(buttonScale)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 28)
        }
        .padding(.top, 26)
        .padding(.bottom, 50)
        .frame(maxWidth: .infinity)
        .background {
            LinearGradient(
                colors: [
                    Color.darkBackground.opacity(0),
                    Color.darkBackground.opacity(0.94),
                    Color.darkBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .transaction { $0.animation = nil }
        }
    }

    private func primaryButtonTapped() {
        HapticManager.shared.impact(.light)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) { buttonScale = 0.95 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) { buttonScale = 1.0 }
            advance()
        }
    }

    private func advance() {
        if currentStep < Self.introStepCount - 1 {
            withAnimation(.easeOut(duration: 0.18)) { contentOpacity = 0 }
            withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) { heroScale = 1.04 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                    currentStep += 1
                    heroScale = 1.0
                }
                withAnimation(.easeIn(duration: 0.28).delay(0.08)) { contentOpacity = 1 }
            }
        } else if currentStep == Self.introStepCount - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                showPaywallStep = true
            }
        }
    }

    private func finalizeKoreaOnboarding() {
        subscriptionService.checkSubscriptionStatus()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            withAnimation {
                viewModel.completeOnboarding()
            }
        }
    }
}
