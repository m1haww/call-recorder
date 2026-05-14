import SwiftUI
import StoreKit

// MARK: - Main Onboarding Flow

struct OnboardingJapanVariant: View {
    @State private var currentScreen = 0
    @State private var showPaywall = false
    @State private var useCasePick = "work"

    @StateObject private var viewModel = AppViewModel.shared
    @StateObject private var subscriptionService = SubscriptionService.shared

    @Environment(\.requestReview) private var requestReview

    private static let totalOnboarding = 7

    var body: some View {
        Group {
            if showPaywall {
                JapanOnboardingPaywallView(onPurchaseSuccess: finalizeOnboarding)
            } else {
                ZStack {
                    // Dark background with green radial gradient at top
                    Color(red: 0.027, green: 0.035, blue: 0.039).ignoresSafeArea()
                    RadialGradient(
                        colors: [
                            Color(red: 0.082, green: 0.125, blue: 0.098),
                            Color(red: 0.027, green: 0.035, blue: 0.039)
                        ],
                        center: UnitPoint(x: 0.5, y: -0.1),
                        startRadius: 0,
                        endRadius: 500
                    )
                    .ignoresSafeArea()

                    screenBody
                        .id(currentScreen)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .animation(.spring(response: 0.42, dampingFraction: 0.88), value: currentScreen)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var screenBody: some View {
        switch currentScreen {
        case 0: JapanWelcomeScreen(onNext: advance)
        case 1: JapanOnbScreen(
                    idx: 1, total: Self.totalOnboarding,
                    tag: "通話録音",
                    headline: "ワンタップで、\n発信・着信を高音質録音。",
                    bodyText: "iPhone の通話画面から、いつもの操作で録音を開始できます。会議・商談・カスタマーサポートなど、聞き逃したくない場面に。",
                    bullets: [
                        ("発信・着信どちらにも対応", "通常の電話・IP電話・国際電話すべて録音可能"),
                        ("最大 48kHz / 320kbps の高音質保存", "相手の声もこちら側もクリアに残ります"),
                        ("長時間の通話でも安定動作", "何時間でも途切れず保存（容量の許す限り）"),
                    ],
                    art: { AnyView(JapanCallMockup()) },
                    ctaLabel: "次へ",
                    onNext: advance
                )
        case 2: JapanOnbScreen(
                    idx: 2, total: Self.totalOnboarding,
                    tag: "AI 文字起こし",
                    headline: "録音した会話を、\n自動でテキストに変換。",
                    bodyText: "日本語に最適化された音声認識エンジンが、敬語・専門用語・話者の切り替えまで正確に書き起こします。聞き直す手間がなくなります。",
                    bullets: [
                        ("日本語ネイティブ精度の文字起こし", "業界用語・固有名詞も学習済みのモデル"),
                        ("話者ごとに自動で分けて表示", "誰が何を話したか一目で確認できます"),
                        ("英語・中国語・韓国語にも対応", "海外との通話も同じ精度でテキスト化"),
                    ],
                    art: { AnyView(JapanTranscriptMockup()) },
                    ctaLabel: "次へ",
                    onNext: advance
                )
        case 3: JapanOnbScreen(
                    idx: 3, total: Self.totalOnboarding,
                    tag: "要約 & 検索",
                    headline: "長い通話も、\n要点だけ 3 秒で把握。",
                    bodyText: "AI が通話内容を要約し、決定事項やタスクを自動で抽出します。あとから「あの話、何だったっけ？」を全文検索で一発解決。",
                    bullets: [
                        ("ワンクリックで自動要約", "15分の通話を3行のサマリーに"),
                        ("アクション項目を自動抽出", "「〜する」を ToDo リストに変換"),
                        ("全文検索で過去の通話から発見", "キーワードを含む録音をすぐに呼び出せます"),
                    ],
                    art: { AnyView(JapanSummaryMockup()) },
                    ctaLabel: "次へ",
                    onNext: advance
                )
        case 4: JapanOnbScreen(
                    idx: 4, total: Self.totalOnboarding,
                    tag: "プライバシー",
                    headline: "あなたの録音は、\nあなただけのもの。",
                    bodyText: "すべての録音とテキストは、業界標準の AES-256 で暗号化され、お客様の許可なく外部に共有されることはありません。安心してお使いください。",
                    bullets: [
                        ("端末内 & iCloud の両方で暗号化保存", "通信経路もエンドツーエンドで保護"),
                        ("広告目的でデータを共有しません", "第三者への販売・提供は一切ありません"),
                        ("いつでもデータを完全削除できます", "退会時はすべての録音が30日以内に消去されます"),
                        ("日本の個人情報保護法に準拠", "プライバシーポリシーで全項目を開示しています"),
                    ],
                    art: { AnyView(JapanPrivacyGraphic()) },
                    ctaLabel: "次へ",
                    onNext: advance
                )
        case 5: JapanUseCaseScreen(idx: 5, total: Self.totalOnboarding, pick: $useCasePick, onNext: advance)
        case 6: JapanOnbScreen(
                    idx: 6, total: Self.totalOnboarding,
                    tag: "クラウド同期",
                    headline: "すべての通話を、\nクラウドに自動バックアップ。",
                    bodyText: "iCloud と連携することで、機種変更や端末紛失時も録音データを安全に守ります。複数の Apple デバイス間で、シームレスに同期されます。",
                    bullets: [
                        ("iCloud 自動バックアップ対応", "何もしなくても、録音が自動で保存されます"),
                        ("iPhone・iPad・Mac で共有", "どの端末からでも同じデータにアクセス"),
                        ("通信量を抑える Wi-Fi のみ同期", "モバイルデータの使いすぎを防止"),
                    ],
                    art: { AnyView(JapanCloudGraphic()) },
                    ctaLabel: "準備完了 · 次へ",
                    onNext: { withAnimation {
                        showPaywall = true
                    }}
                )
        default: EmptyView()
        }
    }

    private func advance() {
        HapticManager.shared.impact(.light)
        withAnimation(.spring(response: 0.42, dampingFraction: 0.88)) {
            currentScreen += 1
        }
    }

    private func finalizeOnboarding() {
        subscriptionService.checkSubscriptionStatus()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            requestReview()
            withAnimation {
                viewModel.completeOnboarding()
            }
        }
    }
}

// MARK: - Progress Bar

private struct JapanProgressBar: View {
    let idx: Int
    let total: Int

    var body: some View {
        HStack(spacing: 4) {
            HStack(spacing: 4) {
                ForEach(0..<total, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 99)
                        .fill(i <= idx ? Color.primaryGreen : Color.white.opacity(0.12))
                        .frame(height: 3)
                        .animation(.easeInOut(duration: 0.3), value: idx)
                }
            }
            Text(String(format: "%02d / %02d", idx + 1, total))
                .font(.system(size: 10.5, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.35))
                .monospacedDigit()
        }
        .padding(.horizontal, 22)
    }
}

// MARK: - Screen 1: Welcome

private struct JapanWelcomeScreen: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 0) {
                // App icon
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.black)
                        .frame(width: 122, height: 122)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.6), radius: 20, x: 0, y: 10)

                    Image(systemName: "phone.fill")
                        .font(.system(size: 64))
                        .foregroundColor(Color.primaryGreen)
                        .frame(width: 122, height: 122)

                    Text("REC")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.red)
                        .clipShape(Capsule())
                        .shadow(color: .red.opacity(0.5), radius: 6, x: 0, y: 3)
                        .offset(x: 5, y: -5)
                }
                .padding(.bottom, 22)

                // Welcome tag
                JapanTag(text: "ようこそ · WELCOME")
                    .padding(.bottom, 14)

                Text("大切な通話を、\n")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
                + Text("一言も逃さない。")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(Color.primaryGreen)

                // Stars row
                HStack(spacing: 8) {
                    Text("★★★★★")
                        .foregroundColor(.yellow)
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 1, height: 10)
                    Text("4.8")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    + Text(" · 12,400件のレビュー")
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.55))
                }
                .padding(.top, 18)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 28)

            Spacer()

            // CTA
            VStack(spacing: 0) {
                Text(
                    (try? AttributedString(markdown:
                        "続行することで[利用規約](https://docs.google.com/document/d/1uSdixI2AsQ32u3aMMekKI9M_eEJH2SNPcr8RLT_DS3Q/edit?usp=sharing)と[プライバシーポリシー](https://docs.google.com/document/d/1uth_ytIH6sL8eJu1w2loQkPMonuRYz-c1yq5xkVK71k/edit?usp=sharing)に同意したものとします。"
                    )) ?? AttributedString("続行することで利用規約とプライバシーポリシーに同意したものとします。")
                )
                .font(.system(size: 10.5))
                .foregroundColor(Color.white.opacity(0.35))
                .multilineTextAlignment(.center)
                .tint(Color.white.opacity(0.5))
                .padding(.bottom, 14)
                
                Button(action: onNext) {
                    HStack {
                        Text("はじめる")
                            .font(.system(size: 17, weight: .bold))
                        Text("→")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.primaryGreen)
                    .foregroundColor(.black)
                    .cornerRadius(16)
                    .shadow(color: Color.primaryGreen.opacity(0.25), radius: 10, x: 0, y: 6)
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 26)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Generic Onboarding Screen Shell

private struct JapanOnbScreen: View {
    let idx: Int
    let total: Int
    let tag: String
    let headline: String
    let bodyText: String
    let bullets: [(String, String)]
    let art: () -> AnyView
    let ctaLabel: String
    let onNext: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            // ── Art fills the full background ──
            VStack(spacing: 0) {
                // Progress bar pinned to top
                JapanProgressBar(idx: idx, total: total)

                // Art expands to fill remaining space
                art()
                    .padding(idx == 6 ? 48 : 16)

                // Spacer so art doesn't sit behind the bottom panel
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // ── Bottom panel overlaid on top of art ──
            VStack(spacing: 0) {
                // Gradient fade from transparent → background so text is readable
                LinearGradient(
                    stops: [
                        .init(color: Color.clear, location: 0),
                        .init(color: Color(red: 0.027, green: 0.035, blue: 0.039).opacity(0.85), location: 0.22),
                        .init(color: Color(red: 0.027, green: 0.035, blue: 0.039), location: 0.5),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 32)

                VStack(alignment: .leading, spacing: 0) {
                    JapanTag(text: tag)

                    Text(headline)
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.white)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                    Text(bodyText)
                        .font(.system(size: 13.5))
                        .foregroundColor(Color.white.opacity(0.7))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    if !bullets.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(bullets.indices, id: \.self) { i in
                                JapanBulletRow(title: bullets[i].0, sub: bullets[i].1)
                            }
                        }
                        .padding(.top, 12)
                    }

                    // CTA button
                    Button(action: onNext) {
                        HStack(spacing: 6) {
                            Text(ctaLabel)
                                .font(.system(size: 17, weight: .bold))
                            Text("→")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(Color.primaryGreen)
                        .foregroundColor(.black)
                        .cornerRadius(16)
                        .shadow(color: Color.primaryGreen.opacity(0.25), radius: 10, x: 0, y: 6)
                    }
                    .padding(.top, 30)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 26)
                .background(Color(red: 0.027, green: 0.035, blue: 0.039))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Screen 6: Use Case Selection

private struct JapanUseCaseScreen: View {
    let idx: Int
    let total: Int
    @Binding var pick: String
    let onNext: () -> Void

    private let cases: [(id: String, emoji: String, title: String, sub: String)] = [
        ("work",     "💼", "仕事 · ビジネス",      "商談・会議・カスタマー対応の記録に"),
        ("personal", "🏠", "個人 · 日常生活",       "家族との約束・大事な連絡を残したい"),
        ("study",    "🎓", "勉強 · インタビュー",   "取材・学習・語学練習の振り返りに"),
    ]

    var body: some View {
        VStack {
            // Progress bar at top
            JapanProgressBar(idx: idx, total: total)

            // Bottom panel
            VStack(alignment: .leading, spacing: 12) {
                JapanTag(text: "用途を教えてください")

                Text("どんな場面で\n使う予定ですか？")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.white)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                Text("選んだ用途に合わせて最適な設定をご提案します。")
                    .font(.system(size: 13.5))
                    .foregroundColor(Color.white.opacity(0.7))
                    .lineSpacing(3)
                    .padding(.bottom, 14)

                VStack(spacing: 8) {
                    ForEach(cases, id: \.id) { c in
                        UseCaseCard(c: c, selected: pick == c.id) {
                            HapticManager.shared.selection()
                            withAnimation(.easeInOut(duration: 0.15)) { pick = c.id }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 22)
            .padding(.top, 22)
            
            Spacer()
            
            Button(action: onNext) {
                HStack(spacing: 6) {
                    Text("選択して次へ")
                        .font(.system(size: 17, weight: .bold))
                    Text("→")
                        .font(.system(size: 17, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(Color.primaryGreen)
                .foregroundColor(.black)
                .cornerRadius(16)
                .shadow(color: Color.primaryGreen.opacity(0.25), radius: 10, x: 0, y: 6)
            }
            .padding(.top, 16)
            .padding(.horizontal, 22)
            .padding(.bottom, 26)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct UseCaseCard: View {
    let c: (id: String, emoji: String, title: String, sub: String)
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Emoji box
                Text(c.emoji)
                    .font(.system(size: 20))
                    .frame(width: 40, height: 40)
                    .background(selected ? Color.primaryGreen : Color.white.opacity(0.05))
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 2) {
                    Text(c.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text(c.sub)
                        .font(.system(size: 11.5))
                        .foregroundColor(Color.white.opacity(0.55))
                        .lineLimit(2)
                }

                Spacer()

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
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(selected ? Color.primaryGreen.opacity(0.10) : Color(red: 0.063, green: 0.078, blue: 0.086))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(selected ? Color.primaryGreen : Color.white.opacity(0.08), lineWidth: selected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Shared UI Components

private struct JapanTag: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(Color.primaryGreen)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.primaryGreen.opacity(0.12))
            .overlay(
                Capsule().stroke(Color.primaryGreen.opacity(0.25), lineWidth: 1)
            )
            .clipShape(Capsule())
            .textCase(.uppercase)
            .kerning(0.8)
    }
}

private struct JapanBulletRow: View {
    let title: String
    let sub: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark")
                .font(.system(size: 10, weight: .black))
                .foregroundColor(Color.primaryGreen)
                .frame(width: 18, height: 18)
                .background(Color.primaryGreen.opacity(0.12))
                .clipShape(Circle())
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                Text(sub)
                    .font(.system(size: 11.5))
                    .foregroundColor(Color.white.opacity(0.4))
                    .lineSpacing(2)
            }
        }
    }
}

// MARK: - Art: Call Mockup

private struct JapanCallMockup: View {
    var body: some View {
        ZStack {
            // Phone bezel
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(red: 0.11, green: 0.12, blue: 0.13))
                .frame(width: 248, height: 460)
                .shadow(color: .black.opacity(0.55), radius: 18, x: 0, y: 8)

            // Screen
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.16, green: 0.20, blue: 0.25),
                            Color(red: 0.074, green: 0.094, blue: 0.11),
                            Color(red: 0.039, green: 0.051, blue: 0.071)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 236, height: 448)

            // Dynamic island
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black)
                .frame(width: 70, height: 18)
                .offset(y: -205)

            // REC banner
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .shadow(color: .red, radius: 4)
                Text("録音中 · REC 00:02:48")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(red: 1, green: 0.851, blue: 0.855))
                    .kerning(0.5)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.red.opacity(0.15))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.red.opacity(0.45), lineWidth: 1)
            )
            .cornerRadius(12)
            .frame(width: 210)
            .offset(y: -160)

            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.23, green: 0.29, blue: 0.37), Color(red: 0.12, green: 0.14, blue: 0.18)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 96, height: 96)
                    .overlay(Circle().stroke(Color.white.opacity(0.08), lineWidth: 1.5))
                Text("田")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.7))
            }
            .offset(y: -54)

            // Name
            VStack(spacing: 2) {
                Text("田中 さん")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text("携帯 · 通話中")
                    .font(.system(size: 11))
                    .foregroundColor(Color.white.opacity(0.55))
            }
            .offset(y: 68)

            // End call button
            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 54, height: 54)
                    .shadow(color: .red.opacity(0.45), radius: 8, x: 0, y: 4)
                Image(systemName: "phone.down.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
            .offset(y: 178)
        }
        .frame(height: 460)
    }
}

// MARK: - Art: Transcript Mockup

private struct JapanTranscriptMockup: View {
    private let lines: [(who: String, text: String, mine: Bool)] = [
        ("田中", "もしもし、お疲れさまです。来週の打ち合わせの件で…", false),
        ("あなた", "はい、水曜日の14時で大丈夫です。", true),
        ("田中", "承知しました。会議室は本社の3階を予約しておきます。", false),
    ]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(red: 0.11, green: 0.12, blue: 0.13))
                .frame(width: 248, height: 460)
                .shadow(color: .black.opacity(0.55), radius: 18, x: 0, y: 8)

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(red: 0.047, green: 0.059, blue: 0.063))
                .frame(width: 236, height: 448)

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black)
                .frame(width: 70, height: 18)
                .offset(y: -205)

            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("田中 さんとの通話")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    Text("2026/05/13 · 14分 28秒")
                        .font(.system(size: 9))
                        .foregroundColor(Color.white.opacity(0.4))
                }
                Spacer()
                Text("AI 文字起こし")
                    .font(.system(size: 8.5, weight: .bold))
                    .foregroundColor(Color.primaryGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.primaryGreen.opacity(0.12))
                    .overlay(
                        Capsule().stroke(Color.primaryGreen.opacity(0.3), lineWidth: 1)
                    )
                    .clipShape(Capsule())
            }
            .frame(width: 210)
            .offset(y: -168)

            // Waveform
            HStack(spacing: 2) {
                ForEach(0..<40, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(i < 20 ? Color.primaryGreen : Color.white.opacity(0.18))
                        .frame(width: 3, height: CGFloat(5 + abs(sin(Double(i) * 0.6)) * 14))
                }
            }
            .frame(width: 210, height: 28)
            .background(Color.white.opacity(0.04))
            .cornerRadius(8)
            .offset(y: -124)

            // Transcript lines
            VStack(alignment: .leading, spacing: 8) {
                ForEach(lines.indices, id: \.self) { i in
                    let l = lines[i]
                    VStack(alignment: .leading, spacing: 3) {
                        Text(l.who)
                            .font(.system(size: 8.5, weight: .bold))
                            .foregroundColor(l.mine ? Color.primaryGreen : Color.white.opacity(0.5))
                        Text(l.text)
                            .font(.system(size: 9.5))
                            .foregroundColor(.white)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .frame(width: 210, alignment: .leading)
                    .background(l.mine ? Color.primaryGreen.opacity(0.10) : Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(l.mine ? Color.primaryGreen.opacity(0.25) : Color.white.opacity(0.06), lineWidth: 1)
                    )
                    .cornerRadius(10)
                }
            }
            .frame(width: 210, alignment: .leading)
            .offset(y: 10)
        }
        .frame(height: 460)
    }
}

// MARK: - Art: Summary Mockup

private struct JapanSummaryMockup: View {
    private let actions = ["資料を火曜までに準備", "会議室3階を予約済み", "議事録を共有する"]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(red: 0.11, green: 0.12, blue: 0.13))
                .frame(width: 248, height: 460)
                .shadow(color: .black.opacity(0.55), radius: 18, x: 0, y: 8)

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(red: 0.047, green: 0.059, blue: 0.063))
                .frame(width: 236, height: 448)

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black)
                .frame(width: 70, height: 18)
                .offset(y: -205)

            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11))
                    .foregroundColor(Color.white.opacity(0.5))
                Text("「来週の打ち合わせ」")
                    .font(.system(size: 10))
                    .foregroundColor(Color.white.opacity(0.8))
                Spacer()
                Text("3件")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Color.primaryGreen)
            }
            .padding(.horizontal, 10)
            .frame(width: 210, height: 30)
            .background(Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .cornerRadius(9)
            .offset(y: -162)

            // Summary card
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    Text("✨ AI 要約")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(Color.primaryGreen)
                }
                .padding(.bottom, 6)

                Text("来週の打ち合わせ調整")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 4)

                Text("水曜日14時に本社3階の会議室で確定。資料は前日までに送付予定。")
                    .font(.system(size: 9))
                    .foregroundColor(Color.white.opacity(0.7))
                    .lineSpacing(2)
            }
            .padding(12)
            .frame(width: 210, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color.primaryGreen.opacity(0.10), Color.primaryGreen.opacity(0.04)],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.primaryGreen.opacity(0.25), lineWidth: 1)
            )
            .cornerRadius(12)
            .offset(y: -90)

            // Action items
            VStack(alignment: .leading, spacing: 0) {
                Text("アクション項目")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.5))
                    .padding(.bottom, 6)

                ForEach(actions.indices, id: \.self) { i in
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(i == 1 ? Color.primaryGreen : Color.white.opacity(0.3), lineWidth: 1.2)
                            .frame(width: 12, height: 12)
                            .overlay(
                                i == 1 ? Image(systemName: "checkmark").font(.system(size: 7, weight: .black)).foregroundColor(Color.primaryGreen) : nil
                            )
                        Text(actions[i])
                            .font(.system(size: 9.5))
                            .foregroundColor(.white)
                            .strikethrough(i == 1)
                            .opacity(i == 1 ? 0.5 : 1)
                    }
                    .padding(.vertical, 6)
                    if i < actions.count - 1 {
                        Rectangle()
                            .fill(Color.white.opacity(0.05))
                            .frame(height: 1)
                    }
                }
            }
            .frame(width: 210, alignment: .leading)
            .offset(y: 60)
        }
        .frame(height: 460)
    }
}

// MARK: - Art: Privacy Graphic

private struct JapanPrivacyGraphic: View {
    var body: some View {
        ZStack {
            // Glow
            RadialGradient(
                colors: [Color.primaryGreen.opacity(0.18), Color.clear],
                center: .center, startRadius: 0, endRadius: 110
            )
            .frame(width: 300, height: 300)

            // Rings
            ForEach([1, 2, 3], id: \.self) { r in
                Circle()
                    .stroke(Color.primaryGreen.opacity(0.18 - Double(r) * 0.04), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .frame(width: CGFloat(100 + r * 54), height: CGFloat(100 + r * 54))
            }

            // Shield
            ShieldShape()
                .fill(
                    LinearGradient(
                        colors: [Color.primaryGreen, Color(red: 0.082, green: 0.639, blue: 0.353)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 100, height: 116)
                .overlay(
                    // Lock icon
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.black.opacity(0.8), lineWidth: 5)
                            .frame(width: 26, height: 18)
                            .offset(y: 20)
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.black.opacity(0.8))
                            .frame(width: 28, height: 24)
                            .overlay(
                                Circle()
                                    .fill(Color.primaryGreen)
                                    .frame(width: 8, height: 8)
                                    .offset(y: -2)
                            )
                    }
                    .offset(y: 10)
                )
                .shadow(color: Color.primaryGreen.opacity(0.4), radius: 16, x: 0, y: 8)

            // AES badge
            Text("AES-256")
                .font(.system(size: 9.5, weight: .black))
                .foregroundColor(Color(red: 0.016, green: 0.075, blue: 0.039))
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(Color.primaryGreen)
                .clipShape(Capsule())
                .offset(x: 70, y: -40)

            // iCloud badge
            Text("iCloud 同期")
                .font(.system(size: 9.5, weight: .black))
                .foregroundColor(Color(red: 0.016, green: 0.075, blue: 0.039))
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(Color.primaryGreen)
                .clipShape(Capsule())
                .offset(x: -68, y: 50)
        }
        .frame(width: 300, height: 300)
    }
}

private struct ShieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addLine(to: CGPoint(x: w, y: h * 0.16))
        path.addLine(to: CGPoint(x: w, y: h * 0.52))
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control1: CGPoint(x: w, y: h * 0.73),
            control2: CGPoint(x: w * 0.73, y: h * 0.88)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: h * 0.52),
            control1: CGPoint(x: w * 0.27, y: h * 0.88),
            control2: CGPoint(x: 0, y: h * 0.73)
        )
        path.addLine(to: CGPoint(x: 0, y: h * 0.16))
        path.closeSubpath()
        return path
    }
}

// MARK: - Art: Cloud Graphic

private struct JapanCloudGraphic: View {
    private let chips = [
        (text: "📞 録音",     offset: CGPoint(x: -68, y: -72)),
        (text: "📝 文字起こし", offset: CGPoint(x:  64, y: -60)),
        (text: "✨ 要約",     offset: CGPoint(x: -60, y:  72)),
        (text: "🔍 検索",     offset: CGPoint(x:  60, y:  64)),
    ]

    var body: some View {
        ZStack {
            // Glow
            RadialGradient(
                colors: [Color.primaryGreen.opacity(0.22), Color.clear],
                center: .center, startRadius: 0, endRadius: 110
            )
            .frame(width: 300, height: 300)

            // Rings
            ForEach([1, 2, 3], id: \.self) { r in
                Circle()
                    .stroke(Color.primaryGreen.opacity(0.18 - Double(r) * 0.04), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .frame(width: CGFloat(100 + r * 54), height: CGFloat(100 + r * 54))
            }

            // Center cloud icon
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.primaryGreen, Color(red: 0.082, green: 0.639, blue: 0.353)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 86, height: 86)
                    .shadow(color: Color.primaryGreen.opacity(0.4), radius: 14, x: 0, y: 6)

                Image(systemName: "icloud.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(red: 0.016, green: 0.075, blue: 0.039))
            }

            // Satellite chips
            ForEach(chips.indices, id: \.self) { i in
                Text(chips[i].text)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.06))
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .clipShape(Capsule())
                    .offset(x: chips[i].offset.x, y: chips[i].offset.y)
            }
        }
        .frame(width: 220, height: 220)
    }
}
