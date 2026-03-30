import RevenueCat
import SwiftUI

struct JapanOnboardingPaywallView: View {
    var onPurchaseSuccess: () -> Void

    private static let offeringId = "default"

    @State private var offering: Offering?
    @State private var selectedPackage: Package?
    @State private var loadFailed = false
    @State private var isPurchasing = false
    @State private var showPurchaseError = false
    @State private var purchaseErrorMessage = ""
    @State private var testimonialOrder: [Int]

    init(onPurchaseSuccess: @escaping () -> Void) {
        self.onPurchaseSuccess = onPurchaseSuccess
        _testimonialOrder = State(initialValue: Self.testimonialIndicesShuffled())
    }

    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color.darkBackground,
                    Color.darkBackground,
                    Color.primaryGreen.opacity(0.07),
                ],
                center: UnitPoint(x: 0.5, y: 0.35),
                startRadius: 40,
                endRadius: 420
            )
            .ignoresSafeArea()

            VStack(spacing: 10) {
                paywallTitleBlock
                    .padding(.horizontal, 12)

                testimonialBlock

                featureTable
                    .padding(.horizontal, 12)

                if offering != nil {
                    Spacer()
                    planOptions
                        .padding(.horizontal, 12)
                } else if loadFailed {
                    Spacer()
                    Text("プランを読み込めませんでした")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                } else {
                    Spacer()
                    ProgressView()
                        .tint(.primaryGreen)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                }

                purchaseButton
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

                Button("購入を復元") {
                    Task { await restorePurchases() }
                }
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 12)
                .padding(.horizontal, 12)
            }
            .padding(.top, 4)
        }
        .preferredColorScheme(.dark)
        .task {
            await loadOffering()
        }
        .alert("エラー", isPresented: $showPurchaseError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(purchaseErrorMessage)
        }
    }

    private var paywallTitleBlock: some View {
        HStack {
            Spacer(minLength: 0)
            ZStack(alignment: .topTrailing) {
                Text("フル録画機能への\nアップグレード")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: true, vertical: false)

                recordIndicator
                    .offset(x: 16, y: -14)
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 12)
        .padding(.bottom, 10)
    }

    private var recordIndicator: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.red.opacity(0.2), lineWidth: 2)
                .frame(width: 28, height: 28)
            Circle()
                .fill(Color.red)
                .frame(width: 12, height: 12)
        }
    }

    private var testimonialBlock: some View {
        TabView {
            ForEach(testimonialOrder, id: \.self) { index in
                let item = Self.testimonialLibrary[index]
                testimonialCard(quote: item.quote, author: item.author)
                    .padding(.horizontal, 12)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 118)
    }

    private func testimonialCard(quote: String, author: String) -> some View {
        VStack(alignment: .center, spacing: 5) {
            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundColor(Color.yellow.opacity(0.9))
                }
            }

            Text(quote)
                .font(.system(size: 13))
                .foregroundColor(.primaryText.opacity(0.92))
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(author)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.tertiaryText)
        }
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity)
    }

    private static func testimonialIndicesShuffled() -> [Int] {
        Array(0..<testimonialLibrary.count).shuffled()
    }

    private static let testimonialLibrary: [(quote: String, author: String)] = [
        (
            "クリアな案内と安定した動作で、毎日の業務通話に欠かせません。",
            "Hiroshi_K"
        ),
        (
            "録音の音質が良く、後から聞き返すのもストレスフリーです。",
            "Yuki_M"
        ),
        (
            "文字起こしの精度が高く、議事メモの作成がとても楽になりました。",
            "Mei_W"
        ),
        (
            "操作がシンプルで、重要なクライアント対応の記録に安心して使っています。",
            "Kenji_T"
        ),
        (
            "自動保存で忘れる心配がなく、アプリのレスポンスも速いです。",
            "Aya_S"
        ),
        (
            "リモート会議の記録から要点整理まで、これひとつで賄えています。",
            "Ryo_N"
        ),
        (
            "プライバシー面も気配りが感じられ、チームでも導入を検討中です。",
            "Naomi_H"
        ),
        (
            "通話後すぐに再生できるのがありがたい。説明どおりの信頼感です。",
            "Takeshi_I"
        ),
    ]

    private var featureTable: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("")
                    .frame(width: 28)
                Text("")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("無料")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondaryText)
                    .frame(width: 44)
                Text("プレミアム")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.primaryGreen)
                    .frame(width: 68)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Divider()
                .background(Color.primaryGreen.opacity(0.25))

            featureRow(icon: "infinity", title: "録音回数無制限")
            featureRow(icon: "speaker.wave.2.fill", title: "高音質")
            featureRow(icon: "waveform", title: "録音の文字起こし")
            featureRow(icon: "list.bullet.rectangle", title: "概要")
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.cardBackground.opacity(0.65))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.primaryGreen.opacity(0.35), lineWidth: 1)
        )
    }

    private func featureRow(icon: String, title: String) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primaryGreen)
                    .frame(width: 28, alignment: .center)

                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondaryText)
                    .frame(width: 44)

                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primaryGreen)
                    .frame(width: 68)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)

            Divider()
                .background(Color.white.opacity(0.06))
        }
    }

    private var planOptions: some View {
        VStack(spacing: 12) {
            if let weekly = offering?.weekly {
                planCard(package: weekly, title: "週刊", subtitle: priceSubtitle(weekly), isPopular: true)
            }
            if let monthly = offering?.monthly {
                planCard(package: monthly, title: "月次", subtitle: priceSubtitle(monthly), isPopular: false)
            }
            if offering?.weekly == nil, offering?.monthly == nil {
                ForEach(offering?.availablePackages ?? [], id: \.identifier) { pkg in
                    planCard(
                        package: pkg,
                        title: pkg.storeProduct.localizedTitle,
                        subtitle: priceSubtitle(pkg),
                        isPopular: false
                    )
                }
            }
        }
    }

    private func planCard(package: Package, title: String, subtitle: String, isPopular: Bool) -> some View {
        let selected = selectedPackage?.identifier == package.identifier
        return Button {
            HapticManager.shared.selection()
            selectedPackage = package
        } label: {
            ZStack(alignment: .topTrailing) {
                HStack(alignment: .center, spacing: 14) {
                    Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(selected ? .primaryGreen : .tertiaryText)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.primaryText)
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 4)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.cardBackground.opacity(0.5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(selected ? Color.primaryGreen : Color.white.opacity(0.12), lineWidth: selected ? 2.5 : 1)
                )

                if isPopular {
                    Text("人気")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.primaryGreen)
                        .clipShape(Capsule())
                        .offset(x: -10, y: -8)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func priceSubtitle(_ package: Package) -> String {
        let price = package.localizedPriceString
        switch package.packageType {
        case .weekly:
            return "その後、\(price) / 週"
        case .monthly:
            return "その後、\(price) / 月"
        default:
            return price
        }
    }

    private var purchaseButton: some View {
        Button {
            Task { await purchaseSelected() }
        } label: {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .tint(.black)
                } else {
                    Text("アップグレード")
                        .font(.system(size: 18, weight: .bold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(canPurchase ? Color.primaryGreen : Color.surfaceBackground)
            )
            .foregroundColor(canPurchase ? .black : .tertiaryText)
        }
        .disabled(!canPurchase || isPurchasing)
        .buttonStyle(.plain)
    }

    private var canPurchase: Bool {
        selectedPackage != nil && offering != nil
    }

    private func loadOffering() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            let resolved = offerings.offering(identifier: Self.offeringId) ?? offerings.current
            await MainActor.run {
                offering = resolved
                if let w = resolved?.weekly {
                    selectedPackage = w
                } else if let m = resolved?.monthly {
                    selectedPackage = m
                } else {
                    selectedPackage = resolved?.availablePackages.first
                }
                loadFailed = resolved == nil
            }
        } catch {
            await MainActor.run {
                loadFailed = true
                offering = nil
            }
        }
    }

    private func purchaseSelected() async {
        guard let pkg = selectedPackage else { return }
        await MainActor.run {
            isPurchasing = true
        }
        do {
            let result = try await Purchases.shared.purchase(package: pkg)
            await MainActor.run {
                isPurchasing = false
                if !result.userCancelled {
                    onPurchaseSuccess()
                }
            }
        } catch {
            await MainActor.run {
                isPurchasing = false
                purchaseErrorMessage = error.localizedDescription
                showPurchaseError = true
            }
        }
    }

    private func restorePurchases() async {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            let unlocked = customerInfo.entitlements.all["Main"]?.isActive == true
            await MainActor.run {
                SubscriptionService.shared.checkSubscriptionStatus()
                if unlocked {
                    onPurchaseSuccess()
                }
            }
        } catch {
            await MainActor.run {
                purchaseErrorMessage = error.localizedDescription
                showPurchaseError = true
            }
        }
    }
}
