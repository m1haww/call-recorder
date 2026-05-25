import RevenueCat
import SwiftUI

struct JapanOnboardingPaywallView: View {
    var onPurchaseSuccess: () -> Void

    @State private var offering: Offering?
    @State private var selectedPackage: Package?
    @State private var loadFailed = false
    @State private var isPurchasing = false
    @State private var showPurchaseError = false
    @State private var purchaseErrorMessage = ""
    @State private var openFaqIndex: Int? = 0

    var body: some View {
        ZStack {
            Color(red: 0.027, green: 0.035, blue: 0.039).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection
                    benefitCardsSection
                    comparisonTableSection
                    planSelectorSection
                    testimonialsSection
                    securityBadgesSection
                    faqSection
                    legalSection

                    // Spacer for the pinned CTA
                    Spacer().frame(height: 90)
                }
            }
            .ignoresSafeArea(edges: .top)

            // Pinned bottom CTA
            VStack(spacing: 0) {
                Spacer()
                bottomCTA
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .preferredColorScheme(.dark)
        .task { await loadOffering() }
        .alert("エラー", isPresented: $showPurchaseError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(purchaseErrorMessage)
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 0) {
            ZStack {
                RadialGradient(
                    colors: [Color.primaryGreen.opacity(0.18), Color.clear],
                    center: .top, startRadius: 0, endRadius: 300
                )
                .frame(height: 320)

                VStack(spacing: 0) {
                    // Crown badge
                    HStack(spacing: 6) {
                        Text("👑")
                        Text("PREMIUM プラン")
                            .font(.system(size: 11, weight: .black))
                    }
                    .foregroundColor(Color(red: 0.227, green: 0.153, blue: 0.024))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 1, green: 0.843, blue: 0.42), Color(red: 0.961, green: 0.62, blue: 0.043)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color(red: 0.961, green: 0.62, blue: 0.043).opacity(0.3), radius: 8, x: 0, y: 3)
                    .padding(.bottom, 16)

                    Text("すべての機能を、\n")
                        .font(.system(size: 26, weight: .black))
                        .foregroundColor(.white)
                        + Text("無制限で。")
                        .font(.system(size: 26, weight: .black))
                        .foregroundColor(Color.primaryGreen)

                    Text("録音・文字起こし・要約・検索 — プロフェッショナルが必要とする全機能を、ひとつのアプリで。")
                        .font(.system(size: 13.5))
                        .foregroundColor(Color.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.top, 12)
                        .padding(.horizontal, 20)

                    // Stars
                    HStack(spacing: 8) {
                        Text("★★★★★")
                            .foregroundColor(.yellow)
                            .font(.system(size: 13))
                        Text("4.8")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        + Text(" · 12,400件のレビュー")
                            .font(.system(size: 12))
                            .foregroundColor(Color.white.opacity(0.55))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.04))
                    .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
                    .clipShape(Capsule())
                    .padding(.top, 18)
                }
                .multilineTextAlignment(.center)
                .padding(.top, 100)
                .padding(.bottom, 24)
            }
        }
        .padding(.top, -26)
    }

    // MARK: - Benefit Cards

    private let benefits: [(n: String, tag: String, h: String, b: String, emoji: String)] = [
        ("01", "無制限の録音",          "回数・時間の制限なし",           "無料版は1日3回・5分まで。プレミアムなら、何時間でも何件でも保存できます。", "🎙️"),
        ("02", "AI 文字起こし",        "全ての通話を自動でテキスト化",    "日本語に最適化された高精度モデル。話者識別・専門用語にも対応します。", "📝"),
        ("03", "AI 要約 & タスク抽出", "長い通話を3行のサマリーに",      "決定事項・アクション項目を自動で抜き出し。会議後の議事録作成がゼロに。", "✨"),
        ("04", "クラウド & エクスポート","無制限のクラウド保存・書き出し", "iCloud 自動バックアップ。MP3・PDF・テキスト・字幕ファイル形式で書き出し可能。", "☁️"),
    ]

    private var benefitCardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("プレミアムでできること")

            ForEach(benefits.indices, id: \.self) { i in
                let b = benefits[i]
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(b.n)
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(Color.primaryGreen)
                            .kerning(0.8)

                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.primaryGreen.opacity(0.10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(Color.primaryGreen.opacity(0.25), lineWidth: 1)
                                )
                                .frame(width: 40, height: 40)

                            Text(b.emoji)
                                .font(.system(size: 20))
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(b.tag)
                            .font(.system(size: 10.5, weight: .bold))
                            .foregroundColor(Color.primaryGreen)
                            .textCase(.uppercase)
                            .kerning(0.4)

                        Text(b.h)
                            .font(.system(size: 14.5, weight: .bold))
                            .foregroundColor(.white)
                            .lineSpacing(2)

                        Text(b.b)
                            .font(.system(size: 12))
                            .foregroundColor(Color.white.opacity(0.55))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(red: 0.063, green: 0.078, blue: 0.086))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Comparison Table

    private let features: [(name: String, free: String?, pro: String?)] = [
        ("録音時間",        "1日 5分まで",   nil),
        ("録音回数",        "1日 3件まで",   nil),
        ("音質",            "標準音質",       "高音質 (320kbps)"),
        ("AI 文字起こし",   nil,             "○"),
        ("AI 要約 & タスク抽出", nil,        "○"),
        ("全文検索",        nil,             "○"),
        ("クラウドバックアップ", nil,         "○"),
        ("MP3 / PDF 書き出し", nil,          "○"),
        ("広告表示",        "あり",           "なし"),
        ("優先サポート",    nil,             "○"),
    ]

    private var comparisonTableSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("無料版とプレミアムの違い")

            VStack(spacing: 0) {
                // Header row
                HStack {
                    Text("機能")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(Color.white.opacity(0.4))
                        .textCase(.uppercase)
                        .kerning(0.4)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("無料")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(Color.white.opacity(0.4))
                        .textCase(.uppercase)
                        .frame(width: 70, alignment: .center)

                    Text("PRO")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(Color.primaryGreen)
                        .textCase(.uppercase)
                        .frame(width: 70, alignment: .center)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.02))

                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)

                ForEach(features.indices, id: \.self) { i in
                    let f = features[i]
                    HStack {
                        Text(f.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Free cell
                        Group {
                            if let free = f.free {
                                if free == "×" || f.free == nil {
                                    Text("×")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color.white.opacity(0.25))
                                } else {
                                    Text(free)
                                        .font(.system(size: 11))
                                        .foregroundColor(Color.white.opacity(0.55))
                                }
                            } else {
                                Text("×")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color.white.opacity(0.25))
                            }
                        }
                        .frame(width: 70, alignment: .center)

                        // Pro cell
                        Group {
                            if let pro = f.pro {
                                if pro == "○" {
                                    Text("○")
                                        .font(.system(size: 16, weight: .black))
                                        .foregroundColor(Color.primaryGreen)
                                } else {
                                    Text(pro)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(Color.primaryGreen)
                                        .multilineTextAlignment(.center)
                                }
                            } else {
                                Text("×")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color.white.opacity(0.25))
                            }
                        }
                        .frame(width: 70, alignment: .center)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)

                    if i < features.count - 1 {
                        Rectangle()
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 1)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(red: 0.063, green: 0.078, blue: 0.086))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal, 22)
        .padding(.top, 22)
        .padding(.bottom, 8)
    }

    // MARK: - Plan Selector

    private var planSelectorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("プランを選ぶ")

            if let offering {
                VStack(spacing: 10) {
                    if let annual = offering.annual {
                        planCard(
                            package: annual,
                            title: "年間プラン",
                            subtitle: "\(annual.localizedPriceString) / 年",
                            perWeek: weeklyEquivalent(annual),
                            badge: "お得",
                            recommended: true
                        )
                    }
                    if let weekly = offering.weekly {
                        planCard(
                            package: weekly,
                            title: "週間プラン",
                            subtitle: "\(weekly.localizedPriceString) / 週",
                            perWeek: "毎週請求",
                            badge: offering.annual == nil ? "人気 No.1" : nil,
                            recommended: offering.annual == nil
                        )
                    }
                    if let monthly = offering.monthly {
                        planCard(
                            package: monthly,
                            title: "月間プラン",
                            subtitle: "\(monthly.localizedPriceString) / 月",
                            perWeek: weeklyEquivalent(monthly),
                            badge: nil,
                            recommended: false
                        )
                    }
                    if offering.weekly == nil, offering.annual == nil, offering.monthly == nil {
                        ForEach(offering.availablePackages, id: \.identifier) { pkg in
                            planCard(
                                package: pkg,
                                title: pkg.storeProduct.localizedTitle,
                                subtitle: pkg.localizedPriceString,
                                perWeek: nil,
                                badge: nil,
                                recommended: false
                            )
                        }
                    }
                }
            } else if loadFailed {
                Text("プランを読み込めませんでした")
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ProgressView()
                    .tint(Color.primaryGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }

            // Reassurance pill
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.primaryGreen.opacity(0.18))
                        .frame(width: 28, height: 28)
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.primaryGreen)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("いつでもキャンセル可能。")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(.white)
                    Text("次回の請求日前に解約すれば料金は発生しません。")
                        .font(.system(size: 11.5))
                        .foregroundColor(Color.white.opacity(0.55))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.primaryGreen.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.primaryGreen.opacity(0.15), lineWidth: 1)
            )
            .cornerRadius(12)
        }
        .padding(.horizontal, 22)
        .padding(.top, 24)
        .padding(.bottom, 8)
    }

    private func planCard(package: Package, title: String, subtitle: String, perWeek: String?, badge: String?, recommended: Bool) -> some View {
        let selected = selectedPackage?.identifier == package.identifier
        return Button {
            HapticManager.shared.selection()
            selectedPackage = package
        } label: {
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 12) {
                    // Radio
                    ZStack {
                        Circle()
                            .fill(selected ? Color.primaryGreen : Color.clear)
                            .frame(width: 22, height: 22)
                        if !selected {
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                                .frame(width: 22, height: 22)
                        }
                        if selected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.black)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 15, weight: .black))
                            .foregroundColor(.white)
                        Text(subtitle)
                            .font(.system(size: 11.5))
                            .foregroundColor(Color.white.opacity(0.55))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(package.localizedPriceString)
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(selected ? Color.primaryGreen : .white)
                        if let pw = perWeek {
                            Text(pw)
                                .font(.system(size: 10))
                                .foregroundColor(Color.white.opacity(0.35))
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(selected ? Color.primaryGreen.opacity(0.08) : Color(red: 0.063, green: 0.078, blue: 0.086))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(selected ? Color.primaryGreen : Color.white.opacity(0.08), lineWidth: selected ? 1.5 : 1)
                )

                // Badge
                if let badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.primaryGreen)
                        .clipShape(Capsule())
                        .offset(x: -10, y: -8)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func weeklyEquivalent(_ pkg: Package) -> String {
        let price = NSDecimalNumber(decimal: pkg.storeProduct.price).doubleValue
        let divisor: Double
        switch pkg.packageType {
        case .annual: divisor = 52.0
        case .monthly: divisor = 4.33
        default: divisor = 1.0
        }
        let perWeek = price / divisor
        let currencyCode = pkg.storeProduct.currencyCode ?? "JPY"
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: perWeek)) ?? ""
        return "約 \(formatted) / 週"
    }

    // MARK: - Testimonials

    private let reviews: [(name: String, meta: String, stars: Int, title: String, body: String)] = [
        ("田中 健一", "営業職 · 36歳 · 東京", 5,
         "商談の議事録作成が10分の1に",
         "お客様との会話を逃さず記録できるので、上司への共有もスムーズ。要約機能のおかげで議事録作成の時間が劇的に減りました。"),
        ("佐藤 美咲", "ライター · 29歳 · 大阪", 5,
         "インタビューの文字起こしが圧倒的に早い",
         "取材音声を自動でテキスト化してくれるので、執筆に集中できるようになりました。日本語の精度がとにかく高い。"),
        ("山本 大輔", "個人事業主 · 42歳 · 福岡", 5,
         "安心して大切な約束を記録",
         "口約束で済むことが多い業界ですが、録音とテキストで残せるので安心。プライバシー設計もしっかりしていて信頼できます。"),
    ]

    private var testimonialsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("ユーザーの声")

            VStack(spacing: 10) {
                ForEach(reviews.indices, id: \.self) { i in
                    let r = reviews[i]
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 10) {
                            // Avatar
                            Text(String(r.name.prefix(1)))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.white.opacity(0.8))
                                .frame(width: 36, height: 36)
                                .background(avatarColor(i))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 1) {
                                Text(r.name)
                                    .font(.system(size: 12.5, weight: .bold))
                                    .foregroundColor(.white)
                                Text(r.meta)
                                    .font(.system(size: 10.5))
                                    .foregroundColor(Color.white.opacity(0.35))
                            }
                            Spacer()
                            Text(String(repeating: "★", count: r.stars))
                                .font(.system(size: 11))
                                .foregroundColor(.yellow)
                        }
                        .padding(.bottom, 8)

                        Text("「\(r.title)」")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .lineSpacing(2)
                            .padding(.bottom, 4)

                        Text(r.body)
                            .font(.system(size: 12))
                            .foregroundColor(Color.white.opacity(0.55))
                            .lineSpacing(3)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(red: 0.063, green: 0.078, blue: 0.086))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                    )
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 24)
        .padding(.bottom, 8)
    }

    private func avatarColor(_ index: Int) -> Color {
        let colors: [Color] = [
            Color(red: 0.29, green: 0.42, blue: 0.54),
            Color(red: 0.66, green: 0.47, blue: 0.35),
            Color(red: 0.42, green: 0.54, blue: 0.35),
        ]
        return colors[index % colors.count]
    }

    // MARK: - Security Badges

    private let badges: [(icon: String, title: String, sub: String)] = [
        ("lock.fill",          "AES-256 暗号化",    "通信・保存ともに保護"),
        ("icloud.fill",        "iCloud 自動同期",   "Apple の安全基準で運用"),
        ("hand.raised.fill",   "広告・追跡なし",    "データを第三者に販売しません"),
        ("trash.fill",         "いつでも完全削除",  "退会時は30日以内に消去"),
    ]

    private var securityBadgesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("セキュリティ & プライバシー")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(badges.indices, id: \.self) { i in
                    let b = badges[i]
                    VStack(alignment: .leading, spacing: 4) {
                        Image(systemName: b.icon)
                            .font(.system(size: 16))
                            .foregroundColor(Color.primaryGreen)
                            .padding(.bottom, 2)

                        Text(b.title)
                            .font(.system(size: 11.5, weight: .bold))
                            .foregroundColor(.white)

                        Text(b.sub)
                            .font(.system(size: 10))
                            .foregroundColor(Color.white.opacity(0.4))
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(red: 0.063, green: 0.078, blue: 0.086))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                    )
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 24)
        .padding(.bottom, 8)
    }

    // MARK: - FAQ

    private let faqs: [(q: String, a: String)] = [
        ("キャンセルはいつでもできますか？",
         "はい。設定 > Apple ID > サブスクリプションからいつでも解約できます。次回の請求日前に解約すれば、料金は発生しません。"),
        ("複数のデバイスで使えますか？",
         "同じ Apple ID でサインインすれば、iPhone・iPad・Mac のすべてでご利用いただけます。録音データも自動で同期されます。"),
        ("録音データは安全に管理されますか？",
         "すべての録音とテキストは AES-256 で暗号化され、お客様の許可なく第三者に共有されることはありません。退会時は30日以内に完全削除されます。"),
        ("機種変更してもデータは引き継げますか？",
         "同じ Apple ID でログインすれば、iCloud 経由ですべての録音・テキストが自動的に復元されます。"),
        ("通話相手にも録音は通知されますか？",
         "通知音は再生されません。録音時の通知については各国・各地域の法令を遵守してご利用ください。"),
    ]

    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("よくある質問")

            VStack(spacing: 0) {
                ForEach(faqs.indices, id: \.self) { i in
                    let f = faqs[i]
                    let isOpen = openFaqIndex == i

                    VStack(alignment: .leading, spacing: 0) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.22)) {
                                openFaqIndex = isOpen ? nil : i
                            }
                        } label: {
                            HStack {
                                Text("Q. \(f.q)")
                                    .font(.system(size: 13.5, weight: .semibold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)

                                Spacer(minLength: 12)

                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.05))
                                        .frame(width: 22, height: 22)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(isOpen ? Color.primaryGreen : Color.white.opacity(0.55))
                                        .rotationEffect(.degrees(isOpen ? 180 : 0))
                                }
                            }
                            .padding(16)
                        }
                        .buttonStyle(.plain)

                        if isOpen {
                            Text("A. \(f.a)")
                                .font(.system(size: 13))
                                .foregroundColor(Color.white.opacity(0.55))
                                .lineSpacing(4)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 14)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    if i < faqs.count - 1 {
                        Rectangle()
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 1)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(red: 0.063, green: 0.078, blue: 0.086))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal, 22)
        .padding(.top, 24)
        .padding(.bottom, 8)
    }

    // MARK: - Legal

    private var legalSection: some View {
        Text("自動更新サブスクリプション。期間終了の24時間前までに解約されない限り、自動的に更新されます。")
            .font(.system(size: 10))
            .foregroundColor(Color.white.opacity(0.25))
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 24)
    }

    // MARK: - Bottom CTA

    private var bottomCTA: some View {
        VStack(spacing: 0) {
            // Fade gradient
            LinearGradient(
                stops: [
                    .init(color: Color.clear, location: 0),
                    .init(color: Color(red: 0.027, green: 0.035, blue: 0.039).opacity(0.95), location: 0.32),
                    .init(color: Color(red: 0.027, green: 0.035, blue: 0.039), location: 0.7),
                ],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 30)

            VStack(spacing: 8) {
                // Main CTA
                Button {
                    Task { await purchaseSelected() }
                } label: {
                    HStack {
                        if isPurchasing {
                            ProgressView().tint(.black)
                        } else {
                            Text("今すぐ始める")
                                .font(.system(size: 17, weight: .bold))
                            Text("→")
                                .font(.system(size: 17, weight: .bold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        canPurchase ? Color.primaryGreen : Color.white.opacity(0.1)
                    )
                    .foregroundColor(canPurchase ? .black : Color.white.opacity(0.35))
                    .cornerRadius(16)
                    .shadow(color: canPurchase ? Color.primaryGreen.opacity(0.25) : .clear, radius: 10, x: 0, y: 5)
                }
                .disabled(!canPurchase || isPurchasing)
                .buttonStyle(.plain)

                HStack {
                    if let url = URL(string: "https://docs.google.com/document/d/1uSdixI2AsQ32u3aMMekKI9M_eEJH2SNPcr8RLT_DS3Q/edit?usp=sharing") {
                        Link("利用規約", destination: url)
                            .font(.system(size: 11.5))
                            .foregroundColor(Color.white.opacity(0.35))
                    }

                    Spacer()

                    if let url = URL(string: "https://docs.google.com/document/d/1uth_ytIH6sL8eJu1w2loQkPMonuRYz-c1yq5xkVK71k/edit?usp=sharing") {
                        Link("プライバシー", destination: url)
                            .font(.system(size: 11.5))
                            .foregroundColor(Color.white.opacity(0.35))
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 36)
            .background(Color(red: 0.027, green: 0.035, blue: 0.039))
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ text: String) -> some View {
        Text("⎯⎯  \(text)")
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(Color.white.opacity(0.35))
            .textCase(.uppercase)
            .kerning(0.8)
    }

    private var canPurchase: Bool {
        selectedPackage != nil && offering != nil
    }

    // MARK: - RevenueCat

    private func loadOffering() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            let resolved = offerings.current
            await MainActor.run {
                offering = resolved
                if let a = resolved?.annual {
                    selectedPackage = a
                } else if let w = resolved?.weekly {
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
        await MainActor.run { isPurchasing = true }
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
                if unlocked { onPurchaseSuccess() }
            }
        } catch {
            await MainActor.run {
                purchaseErrorMessage = error.localizedDescription
                showPurchaseError = true
            }
        }
    }
}
