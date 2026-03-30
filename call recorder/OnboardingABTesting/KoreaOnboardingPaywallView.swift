import RevenueCat
import SwiftUI

struct KoreaOnboardingPaywallView: View {
    var onPurchaseSuccess: () -> Void

    private static let offeringId = "default"

    @State private var offering: Offering?
    @State private var selectedPackage: Package?
    @State private var loadFailed = false
    @State private var isPurchasing = false
    @State private var showPurchaseError = false
    @State private var purchaseErrorMessage = ""

    var body: some View {
        ZStack {
            koreaPaywallBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                discountTitleBlock
                    .padding(.top, 32)

                featureList
                    .padding(.top, -32)

                Spacer()

                if offering != nil {
                    planOptions
                } else if loadFailed {
                    Text("요금제를 불러오지 못했습니다")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                } else {
                    ProgressView()
                        .tint(.primaryGreen)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                }

                purchaseButton
                    .padding(.top, 22)

                Button("구매 복원") {
                    Task { await restorePurchases() }
                }
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .preferredColorScheme(.dark)
        .task {
            await loadOffering()
        }
        .alert("오류", isPresented: $showPurchaseError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(purchaseErrorMessage)
        }
    }

    private var koreaPaywallBackground: some View {
        ZStack {
            Color.darkBackground
            
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
        .ignoresSafeArea()
    }

    private var discountTitleBlock: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 2) {
                Text("50% 할인")
                    .font(.system(size: 38, weight: .heavy))
                    .foregroundColor(Color(hex: "FF1C1C"))
                
                Text("오늘만")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Image("red-arrow")
                .resizable()
                .scaledToFit()
                .frame(width: 240, height: 240)
                .offset(x: 72, y: -106)
                .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 26) {
            koreaFeatureRow(icon: "infinity", title: "무제한 녹음")
            koreaFeatureRow(icon: "speaker.wave.2.fill", title: "고음질 오디오")
            koreaFeatureRow(icon: "waveform", title: "녹음 내용 필사본")
            koreaFeatureRow(icon: "list.bullet.rectangle", title: "요약")
        }
    }

    private func koreaFeatureRow(icon: String, title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.primaryGreen)
                .frame(width: 28, alignment: .center)
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primaryText)
            Spacer(minLength: 0)
        }
    }

    private var planOptions: some View {
        VStack(spacing: 12) {
            if let weekly = offering?.weekly {
                koreaPlanCard(
                    package: weekly,
                    title: "주간",
                    subtitle: priceSubtitle(weekly),
                    showsDiscountRibbon: true,
                    isPopular: true
                )
            }
            if let monthly = offering?.monthly {
                koreaPlanCard(
                    package: monthly,
                    title: "월간",
                    subtitle: priceSubtitle(monthly),
                    showsDiscountRibbon: false,
                    isPopular: false
                )
            }
            if offering?.weekly == nil, offering?.monthly == nil {
                ForEach(offering?.availablePackages ?? [], id: \.identifier) { pkg in
                    koreaPlanCard(
                        package: pkg,
                        title: pkg.storeProduct.localizedTitle,
                        subtitle: priceSubtitle(pkg),
                        showsDiscountRibbon: false,
                        isPopular: false
                    )
                }
            }
        }
    }

    private func koreaPlanCard(
        package: Package,
        title: String,
        subtitle: String,
        showsDiscountRibbon: Bool,
        isPopular: Bool
    ) -> some View {
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

                    Spacer(minLength: 8)

                    if showsDiscountRibbon {
                        Text("50% 할인")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "FF1C1C"))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.cardBackground.opacity(0.45))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(strokeColor(selected: selected, isPopular: isPopular), lineWidth: isPopular ? 2 : 1)
                )

                if isPopular {
                    Text("인기")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(hex: "FF1C1C"))
                        .clipShape(Capsule())
                        .offset(x: -8, y: -10)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func strokeColor(selected: Bool, isPopular: Bool) -> Color {
        if isPopular {
            return selected ? Color.red.opacity(0.95) : Color.red.opacity(0.55)
        }
        return selected ? Color.primaryGreen : Color.white.opacity(0.14)
    }

    private func priceSubtitle(_ package: Package) -> String {
        let price = package.localizedPriceString
        switch package.packageType {
        case .weekly:
            return "그 후 \(price) / 주"
        case .monthly:
            return "그 후 \(price) / 월"
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
                    Text("업그레이드")
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
