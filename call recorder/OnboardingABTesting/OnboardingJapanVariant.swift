import SwiftUI
import StoreKit

struct OnboardingJapanVariant: View {
    @State private var introPage = 0
    @State private var showPaywallStep = false
    @State private var buttonScale: CGFloat = 1.0

    @StateObject private var viewModel = AppViewModel.shared
    @StateObject private var subscriptionService = SubscriptionService.shared

    @Environment(\.requestReview) private var requestReview

    private static let introStepCount = 3

    private static let steps: [(asset: String, title: String, subtitle: String)] = [
        (
            "japan-1",
            "重要な通話を安全に録音する",
            "通話、会議、メモを高音質で録音・記録します。安全に保存され、いつでも簡単にアクセスできます。"
        ),
        (
            "japan-2",
            "シンプルで信頼性の高い録音",
            "通話中に録音を開始　自動保存　いつでも再生可能"
        ),
        (
            "japan-3",
            "お客様のプライバシーを最優先に",
            "すべての記録は安全なストレージで保護されています。お客様の許可なくデータが共有されることはありません。"
        )
    ]

    var body: some View {
        Group {
            if showPaywallStep {
                JapanOnboardingPaywallView(
                    onPurchaseSuccess: finalizeJapanOnboarding
                )
            } else {
                ZStack {
                    Color.darkBackground.ignoresSafeArea()
                    
                    japanBackgroundGradient
                        .ignoresSafeArea()

                    TabView(selection: $introPage) {
                        ForEach(0..<Self.introStepCount, id: \.self) { index in
                            japanIntroPage(index: index)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var japanBackgroundGradient: some View {
        LinearGradient(
            stops: [
                .init(color: Color.primaryGreen.opacity(0.01), location: 0.74),
                .init(color: Color.primaryGreen.opacity(0.06), location: 0.9),
                .init(color: Color.primaryGreen.opacity(0.1), location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func japanIntroPage(index: Int) -> some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    heroImage(geometry: geometry, index: index)
                        .padding(.top, index == 2 ? geometry.safeAreaInsets.top : geometry.safeAreaInsets.top * 0.15)

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack {
                    Spacer()
                    bottomPanel(for: index)
                }
            }
        }
    }

    @ViewBuilder
    private func heroImage(geometry: GeometryProxy, index: Int) -> some View {
        let maxWidth = min(geometry.size.width - 48, 340)

        Image(Self.steps[index].asset)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: maxWidth)
    }

    private func bottomPanel(for index: Int) -> some View {
        VStack(spacing: 28) {
            VStack(alignment: .leading, spacing: 12) {
                Text(Self.steps[index].title)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(Self.steps[index].subtitle)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.white.opacity(0.92))
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 28)

            Button(action: { introButtonTapped(currentIndex: index) }) {
                Text(index == 0 ? "はじめに" : "次へ")
                    .font(.system(size: 19, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.primaryGreen)
                    .foregroundColor(.black)
                    .cornerRadius(28)
                    .scaleEffect(buttonScale)
            }
            .padding(.horizontal, 26)
        }
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity)
    }

    private func introButtonTapped(currentIndex: Int) {
        HapticManager.shared.impact(.light)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) { buttonScale = 0.95 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) { buttonScale = 1.0 }
            if currentIndex < Self.introStepCount - 1 {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
                    introPage = currentIndex + 1
                }
            } else {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                    showPaywallStep = true
                }
            }
        }
    }

    private func finalizeJapanOnboarding() {
        subscriptionService.checkSubscriptionStatus()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            requestReview()
            withAnimation {
                viewModel.completeOnboarding()
            }
        }
    }
}
