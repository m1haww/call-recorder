import SwiftUI
import StoreKit

struct OnboardingVariantE: View {
    @StateObject private var viewModel = AppViewModel.shared
    @StateObject private var subscriptionService = SubscriptionService.shared

    @State private var currentStep = 0
    @State private var contentOpacity: Double = 0

    @Environment(\.requestReview) var requestReview

    private static let stepCount = 5

    var body: some View {
        ZStack {
            Color.darkBackground.opacity(0.5).ignoresSafeArea()
            VariantE_BackgroundMesh()

            Group {
                switch currentStep {
                case 0: VariantE_WelcomeScreen(onNext: advance)
                case 1: VariantE_RecordingScreen(onNext: advance)
                case 2: VariantE_TranscriptScreen(onNext: advance)
                case 3: VariantE_OrganizeScreen(onNext: advance)
                case 4: VariantE_TrustScreen(onNext: {
                    requestReview()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
                        advance()
                    }
                })
                case 5: VariantE_PersonalizeScreen(onNext: advance)
                case 6: VariantE_LoadingScreen(onDone: finish)
                default: EmptyView()
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            ))
            .id(currentStep)
        }
        .preferredColorScheme(.dark)
    }

    private func advance() {
        HapticManager.shared.impact(.light)
        withAnimation(.spring(response: 0.38, dampingFraction: 1)) {
            currentStep += 1
        }
    }

    private func finish() {
        HapticManager.shared.impact(.light)
        subscriptionService.showPaywall = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            withAnimation {
                viewModel.completeOnboarding()
            }
        }
    }
}

// MARK: - Background mesh (subtle green radial glow)

private struct VariantE_BackgroundMesh: View {
    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    Color.primaryGreen.opacity(0.12),
                    Color.darkBackground.opacity(0)
                ],
                center: UnitPoint(x: 0.5, y: 0.25),
                startRadius: 0,
                endRadius: 380
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Shared layout chrome

private struct VariantE_CTAButton: View {
    let label: String
    var disabled: Bool = false
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: {
            guard !disabled else { return }
            HapticManager.shared.impact(.light)
            withAnimation(.spring(response: 0.18, dampingFraction: 0.6)) { pressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { pressed = false }
                action()
            }
        }) {
            HStack(spacing: 8) {
                Text(label)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                if label == String(localized: "onboarding_e_get_started") {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .bold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                LinearGradient(
                    colors: disabled
                    ? [Color.primaryGreen.opacity(0.3), Color.accentGreen.opacity(0.3)]
                        : [Color.primaryGreen, Color.accentGreen],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(disabled ? .secondaryText : .black)
            .cornerRadius(28)
            .scaleEffect(pressed ? 0.97 : 1)
            .opacity(disabled ? 0.45 : 1)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }
}

private struct VariantE_Dots: View {
    let total: Int
    let active: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { i in
                Capsule()
                    .fill(i == active ? Color.primaryGreen : Color.surfaceBackground.opacity(0.8))
                    .frame(width: i == active ? 20 : 6, height: 6)
                    .animation(.spring(response: 0.35, dampingFraction: 0.65), value: active)
            }
        }
    }
}

// MARK: - Screen 1: Welcome / Hero

private struct VariantE_WelcomeScreen: View {
    let onNext: () -> Void

    @State private var appear = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Hero: pulsing mic circle
            ZStack {
                VariantE_PulseRings()
                    .opacity(appear ? 1 : 0)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "#5fff52"), Color(hex: "#2bc822")],
                            center: UnitPoint(x: 0.3, y: 0.3),
                            startRadius: 0,
                            endRadius: 90
                        )
                    )
                    .frame(width: 132, height: 132)
                    .shadow(color: Color.primaryGreen.opacity(0.55), radius: 40, x: 0, y: 0)
                    .overlay(
                        Circle()
                            .stroke(Color.primaryGreen.opacity(0.4), lineWidth: 1)
                    )
                    .overlay(
                        Image(systemName: "mic.fill")
                            .font(.system(size: 52, weight: .medium))
                            .foregroundColor(Color(hex: "#062a04"))
                    )
                    .scaleEffect(appear ? 1 : 0.7)
            }
            .frame(height: 280)
            .opacity(appear ? 1 : 0)

            // App badge
            HStack(spacing: 8) {
                Circle()
                    .fill(LinearGradient(colors: [Color.primaryGreen, Color.accentGreen], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 26, height: 26)
                    .overlay(
                        Image(systemName: "phone.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    )
                Text(String(localized: "onboarding_e_app_name"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primaryText)
            }
            .opacity(appear ? 1 : 0)
            .padding(.bottom, 20)

            // Headline
            VStack(spacing: 0) {
                Text(String(localized: "onboarding_e_welcome_headline"))
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundColor(.primaryText)
                Text(String(localized: "onboarding_e_welcome_headline_accent"))
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#5fff52"), Color.primaryGreen],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.primaryGreen.opacity(0.4), radius: 16, x: 0, y: 0)
            }
            .multilineTextAlignment(.center)
            .opacity(appear ? 1 : 0)

            Spacer()

            // CTA
            VariantE_CTAButton(label: String(localized: "onboarding_e_get_started"), action: onNext)
                .padding(.horizontal, 28)
                .padding(.bottom, 26)
                .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.1)) {
                appear = true
            }
        }
    }
}

// MARK: - Screen 3: Trust / Social proof

private struct VariantE_TrustScreen: View {
    let onNext: () -> Void


    @State private var appear = false

    private var stats: [(String, String)] {
        [
            ("120M+", String(localized: "onboarding_e_stat_calls")),
            ("99.2%", String(localized: "onboarding_e_stat_accuracy")),
            ("180+",  String(localized: "onboarding_e_stat_countries")),
        ]
    }

    private var testimonials: [(name: String, role: String, quote: String)] {
        [
            (name: "Sarah K.",  role: String(localized: "onboarding_e_testimonial_role_1"), quote: String(localized: "onboarding_e_testimonial_quote_1")),
            (name: "Marcus T.", role: String(localized: "onboarding_e_testimonial_role_2"), quote: String(localized: "onboarding_e_testimonial_quote_2")),
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Rating badge + headline
                    VStack(spacing: 12) {
                        HStack(spacing: 6) {
                            VariantE_Stars()
                            Text(String(localized: "onboarding_e_trust_rating_badge"))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.primaryGreen)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.primaryGreen.opacity(0.1))
                        .overlay(
                            Capsule().stroke(Color.primaryGreen.opacity(0.2), lineWidth: 1)
                        )
                        .clipShape(Capsule())

                        Text(String(localized: "onboarding_e_trust_headline"))
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                    }
                    .padding(.top, 64)
                    .opacity(appear ? 1 : 0)

                    // Stats row
                    HStack(alignment: .top, spacing: 8) {
                        ForEach(stats, id: \.0) { stat in
                            VStack(spacing: 4) {
                                Text(stat.0)
                                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                                    .foregroundColor(.primaryGreen)
                                Text(stat.1)
                                    .font(.system(size: 11))
                                    .foregroundColor(.tertiaryText)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 28)
                    .padding(.horizontal, 20)
                    .opacity(appear ? 1 : 0)

                    // Testimonials
                    VStack(spacing: 10) {
                        ForEach(testimonials, id: \.name) { t in
                            VStack(alignment: .leading, spacing: 8) {
                                VariantE_Stars()
                                Text(t.quote)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "#e8efe8"))
                                    .lineSpacing(3)
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(LinearGradient(colors: [Color.primaryGreen, Color.accentGreen], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            Text(String(t.name.prefix(1)))
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(Color(hex: "#062a04"))
                                        )
                                    Text("\(t.name) · \(t.role)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondaryText)
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.top, 14)
                    .padding(.horizontal, 20)
                    .opacity(appear ? 1 : 0)

                    Spacer(minLength: 24)
                }
            }

            // CTA
            VStack(spacing: 18) {
                VariantE_Dots(total: 5, active: 3)
                VariantE_CTAButton(label: String(localized: "Continue"), action: onNext)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 26)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) { appear = true }
        }
    }
}

// MARK: - Screen 2: Recording demo

private struct VariantE_RecordingScreen: View {
    let onNext: () -> Void

    @State private var appear = false
    @State private var isRecording = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Mock call card
            VStack(spacing: 0) {
                // Card header: contact + REC badge
                HStack(spacing: 12) {
                    Circle()
                        .fill(LinearGradient(colors: [Color(hex: "#6b7280"), Color(hex: "#374151")], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 42, height: 42)
                        .overlay(
                            Text("EM")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        )
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "onboarding_e_recording_contact_name"))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primaryText)
                        Text(String(localized: "onboarding_e_recording_contact_detail"))
                            .font(.system(size: 12))
                            .foregroundColor(.secondaryText)
                    }
                    Spacer()
                    // REC indicator
                    HStack(spacing: 5) {
                        Circle()
                            .fill(isRecording ? Color.red : Color(hex: "#6b7280"))
                            .frame(width: 8, height: 8)
                            .opacity(isRecording ? 1 : 0.6)
                        Text(isRecording ? String(localized: "onboarding_e_recording_rec_active") : String(localized: "onboarding_e_recording_rec_idle"))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(isRecording ? Color(hex: "#ff6b63") : .tertiaryText)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(isRecording ? Color.red.opacity(0.15) : Color.white.opacity(0.06))
                    .cornerRadius(999)
                    .overlay(
                        Capsule()
                            .stroke(isRecording ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
                    .animation(.easeInOut(duration: 0.3), value: isRecording)
                }
                .padding(.bottom, 18)

                // Waveform
                VariantE_Waveform(isActive: isRecording)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 16)
                    .frame(height: 88)
                    .frame(maxWidth: .infinity)
                    .background(Color.primaryGreen.opacity(0.05))
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.primaryGreen.opacity(0.18), lineWidth: 1)
                    )
            }
            .padding(22)
            .background(
                Color.gray.opacity(0.1)
            )
            .cornerRadius(28)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.4), radius: 30, x: 0, y: 16)
            .padding(.horizontal, 24)
            .opacity(appear ? 1 : 0)

            Spacer(minLength: 28)

            // Title + feature pills
            VStack(spacing: 16) {
                Text(String(localized: "onboarding_e_recording_title"))
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)

                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        VariantE_FeaturePill(icon: "bolt.fill", text: String(localized: "onboarding_e_pill_auto_record"))
                        VariantE_FeaturePill(icon: "checkmark.shield.fill", text: String(localized: "onboarding_e_pill_hd_quality"))
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    
                    VariantE_FeaturePill(icon: "icloud.fill", text: String(localized: "onboarding_e_pill_cloud_backup"))
                }
            }
            .padding(.horizontal, 28)
            .opacity(appear ? 1 : 0)

            Spacer()

            VStack(spacing: 18) {
                VariantE_Dots(total: 5, active: 0)
                VariantE_CTAButton(label: String(localized: "Continue"), action: onNext)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 26)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.35).delay(0.1)) { appear = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.4)) { isRecording = true }
            }
        }
    }
}

// MARK: - Screen 4: Transcript demo

private struct VariantE_TranscriptScreen: View {
    let onNext: () -> Void


    @State private var appear = false
    @State private var visibleLines = 0

    private var lines: [(who: String, text: String)] {
        [
            (who: "them", text: String(localized: "onboarding_e_transcript_line_1")),
            (who: "me",   text: String(localized: "onboarding_e_transcript_line_2")),
            (who: "them", text: String(localized: "onboarding_e_transcript_line_3")),
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // AI Transcript card
            VStack(alignment: .leading, spacing: 14) {
                // Card header
                HStack(spacing: 8) {
                    HStack(spacing: 5) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.primaryGreen)
                        Text(String(localized: "onboarding_e_transcript_badge"))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.primaryGreen)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.primaryGreen.opacity(0.12))
                    .cornerRadius(999)

                    Text(String(localized: "onboarding_e_transcript_live"))
                        .font(.system(size: 11))
                        .foregroundColor(.tertiaryText)

                    Spacer()
                }

                // Chat bubbles
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(0..<min(visibleLines, lines.count), id: \.self) { i in
                        let line = lines[i]
                        VStack(alignment: line.who == "me" ? .trailing : .leading, spacing: 2) {
                            Text(line.who == "me" ? String(localized: "onboarding_e_transcript_speaker_me") : String(localized: "onboarding_e_transcript_speaker_them"))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(line.who == "me" ? Color.primaryGreen.opacity(0.7) : Color.secondaryText.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: line.who == "me" ? .trailing : .leading)

                            Text(line.text)
                                .font(.system(size: 13.5))
                                .foregroundColor(line.who == "me" ? Color(hex: "#e8ffd8") : Color(hex: "#e8efe8"))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(line.who == "me" ? Color.primaryGreen.opacity(0.18) : Color.white.opacity(0.06))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            line.who == "me" ? Color.primaryGreen.opacity(0.3) : Color.white.opacity(0.08),
                                            lineWidth: 1
                                        )
                                )
                                .frame(maxWidth: .infinity, alignment: line.who == "me" ? .trailing : .leading)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // Typing indicator
                    if visibleLines < lines.count {
                        VariantE_TypingDots()
                            .transition(.opacity)
                    }
                }
            }
            .padding(18)
            .background(
                Color.gray.opacity(0.1)
            )
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 12)
            .padding(.horizontal, 24)
            .frame(minHeight: 260)
            .opacity(appear ? 1 : 0)

            Spacer(minLength: 28)

            Text(String(localized: "onboarding_e_transcript_title"))
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .opacity(appear ? 1 : 0)

            Spacer()

            VStack(spacing: 18) {
                VariantE_Dots(total: 5, active: 1)
                VariantE_CTAButton(label: String(localized: "Continue"), action: onNext)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 26)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.35).delay(0.1)) { appear = true }
            // Stagger chat bubbles appearing
            let delays = [0.5, 1.3, 2.2]
            for (i, delay) in delays.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        visibleLines = i + 1
                    }
                }
            }
        }
    }
}

// MARK: - Screen 5: Organize

private struct VariantE_OrganizeScreen: View {
    let onNext: () -> Void

    @State private var appear = false
    @State private var selectedFilter = 1 // 0=All, 1=Today, 2=Week

    private let filters = [
        String(localized: "onboarding_e_organize_filter_all"),
        String(localized: "onboarding_e_organize_filter_today"),
        String(localized: "onboarding_e_organize_filter_week"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)

            // Card stack
            VStack(spacing: 12) {
                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                    Text(String(localized: "onboarding_e_organize_search_placeholder"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(14)

                // Segmented filter
                HStack(spacing: 0) {
                    ForEach(filters.indices, id: \.self) { i in
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) { selectedFilter = i }
                        } label: {
                            Text(filters[i])
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(selectedFilter == i ? .white : .white.opacity(0.5))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    selectedFilter == i
                                        ? Color.primaryGreen.opacity(0.18)
                                        : Color.clear
                                )
                                .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(3)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(13)

                // Recording cards
                VStack(spacing: 10) {
                    VariantE_RecordingCard(
                        initials: "CR",
                        name: String(localized: "onboarding_e_organize_card1_name"),
                        number: "+1 520 244 5872",
                        time: "13:39",
                        duration: "0:08",
                        date: String(localized: "onboarding_e_organize_card1_date")
                    )
                    VariantE_RecordingCard(
                        initials: "EM",
                        name: String(localized: "onboarding_e_organize_card2_name"),
                        number: "+1 415 992 3010",
                        time: "11:02",
                        duration: "18:24",
                        date: String(localized: "onboarding_e_organize_card2_date")
                    )
                }
            }
            .padding(.horizontal, 24)
            .opacity(appear ? 1 : 0)

            Spacer(minLength: 20)

            Text(String(localized: "onboarding_e_organize_title"))
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .opacity(appear ? 1 : 0)

            Spacer()

            VStack(spacing: 18) {
                VariantE_Dots(total: 5, active: 2)
                VariantE_CTAButton(label: String(localized: "Continue"), action: onNext)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 26)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.35).delay(0.1)) { appear = true }
        }
    }
}

private struct VariantE_RecordingCard: View {
    let initials: String
    let name: String
    let number: String
    let time: String
    let duration: String
    let date: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                // Green phone avatar
                Circle()
                    .fill(LinearGradient(colors: [Color.primaryGreen, Color.accentGreen], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 40, height: 40)
                    .shadow(color: Color.primaryGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                    .overlay(
                        Image(systemName: "phone.fill")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Color(hex: "#062a04"))
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primaryText)
                    Text(number)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.55))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(time)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.55))
                    Text(duration)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primaryGreen)
                }
            }
            Text(date)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.4))

            // Action buttons
            HStack(spacing: 8) {
                // Play
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "#062a04"))
                    Text(String(localized: "onboarding_e_organize_play"))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "#062a04"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(Color.primaryGreen.opacity(0.85))
                .cornerRadius(999)
                .shadow(color: Color.primaryGreen.opacity(0.25), radius: 8, x: 0, y: 4)

                // Share
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 38, height: 38)
                    .overlay(Circle().stroke(Color.white.opacity(0.06), lineWidth: 1))
                    .overlay(
                        Image(systemName: "arrowshape.turn.up.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primaryGreen)
                    )

                // Delete
                Circle()
                    .fill(Color.red.opacity(0.08))
                    .frame(width: 38, height: 38)
                    .overlay(Circle().stroke(Color.red.opacity(0.12), lineWidth: 1))
                    .overlay(
                        Image(systemName: "trash")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.red.opacity(0.7))
                    )
            }
        }
        .padding(14)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.04), lineWidth: 1)
        )
    }
}

private struct VariantE_PersonalizeScreen: View {
    let onNext: () -> Void


    @State private var appear = false
    @State private var picked: String? = nil

    private var options: [(id: String, icon: String, label: String, sub: String)] {
        [
            (id: "work",     icon: "briefcase.fill",  label: String(localized: "onboarding_e_personalize_option_work"),     sub: String(localized: "onboarding_e_personalize_sub_work")),
            (id: "sales",    icon: "bolt.fill",        label: String(localized: "onboarding_e_personalize_option_sales"),    sub: String(localized: "onboarding_e_personalize_sub_sales")),
            (id: "legal",    icon: "scalemass.fill",   label: String(localized: "onboarding_e_personalize_option_legal"),    sub: String(localized: "onboarding_e_personalize_sub_legal")),
            (id: "memories", icon: "heart.fill",       label: String(localized: "onboarding_e_personalize_option_memories"), sub: String(localized: "onboarding_e_personalize_sub_memories")),
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(String(localized: "onboarding_e_personalize_title"))
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.primaryText)
                Text(String(localized: "onboarding_e_personalize_subtitle"))
                    .font(.system(size: 15))
                    .foregroundColor(.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 76)
            .opacity(appear ? 1 : 0)
            .padding(.bottom, 20)

            VStack(spacing: 10) {
                ForEach(options.indices, id: \.self) { i in
                    let opt = options[i]
                    let isSelected = picked == opt.id
                    Button {
                        HapticManager.shared.selection()
                        withAnimation(.easeInOut(duration: 0.18)) { picked = opt.id }
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isSelected ? Color.primaryGreen.opacity(0.18) : Color.white.opacity(0.04))
                                    .frame(width: 42, height: 42)
                                Image(systemName: opt.icon)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(isSelected ? .primaryGreen : .secondaryText)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(opt.label)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.primaryText)
                                Text(opt.sub)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondaryText)
                            }
                            Spacer()
                            // Radio button
                            Circle()
                                .fill(isSelected ? Color.primaryGreen : Color.clear)
                                .frame(width: 22, height: 22)
                                .overlay(
                                    Circle()
                                        .stroke(isSelected ? Color.primaryGreen : Color.surfaceBackground, lineWidth: 2)
                                )
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(Color(hex: "#062a04"))
                                        .opacity(isSelected ? 1 : 0)
                                )
                        }
                        .padding(16)
                        .background(isSelected ? Color.primaryGreen.opacity(0.1) : Color.surfaceBackground.opacity(0.5))
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    isSelected ? Color.primaryGreen : Color.white.opacity(0.07),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(
                            color: isSelected ? Color.primaryGreen.opacity(0.18) : .clear,
                            radius: 12, x: 0, y: 0
                        )
                        .animation(.easeInOut(duration: 0.18), value: isSelected)
                    }
                    .buttonStyle(.plain)
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.35).delay(Double(i) * 0.07 + 0.15), value: appear)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Spacer()

            VStack(spacing: 18) {
                VariantE_Dots(total: 5, active: 4)
                VariantE_CTAButton(
                    label: String(localized: "Continue"),
                    disabled: picked == nil,
                    action: onNext
                )
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 26)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.35).delay(0.05)) { appear = true }
        }
    }
}

// MARK: - Reusable sub-components

private struct VariantE_PulseRings: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(Color.primaryGreen.opacity(0.18 - Double(i) * 0.05), lineWidth: 1.5)
                    .frame(width: CGFloat(200 + i * 56), height: CGFloat(200 + i * 56))
                    .scaleEffect(animate ? 1 : 0.7)
                    .opacity(animate ? 1 : 0)
                    .animation(
                        .easeInOut(duration: 2.2)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.35),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}

private struct VariantE_Stars: View {
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.primaryGreen)
            }
        }
    }
}

private struct VariantE_FeaturePill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primaryGreen)
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primaryText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.primaryGreen.opacity(0.1))
        .cornerRadius(999)
        .overlay(
            Capsule()
                .stroke(Color.primaryGreen.opacity(0.2), lineWidth: 1)
        )
    }
}

private struct VariantE_Waveform: View {
    var isActive: Bool

    // 28 bars — close to what the screenshot shows
    private let barCount = 28
    // Pre-baked "natural" height profile so even the static state looks good
    private let baseHeights: [CGFloat] = [
        0.35, 0.55, 0.75, 0.90, 0.70, 0.85, 0.60, 0.95,
        0.80, 0.65, 0.90, 0.75, 0.55, 0.85, 0.70, 0.95,
        0.60, 0.80, 0.90, 0.70, 0.85, 0.55, 0.75, 0.90,
        0.65, 0.80, 0.50, 0.40,
    ]

    @State private var animHeights: [CGFloat] = Array(repeating: 0.5, count: 28)
    @State private var timer: Timer? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(0..<barCount, id: \.self) { i in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.primaryGreen, Color.accentGreen],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 5, height: isActive ? animHeights[i] * 56 : baseHeights[i] * 20)
                    .animation(.easeInOut(duration: 0.18), value: animHeights[i])
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            animHeights = baseHeights
            if isActive { startAnimation() }
        }
        .onChange(of: isActive) { active in
            if active { startAnimation() } else { stopAnimation() }
        }
        .onDisappear { stopAnimation() }
    }

    private func startAnimation() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.10, repeats: true) { _ in
            for i in 0..<barCount {
                let base = baseHeights[i]
                let jitter = CGFloat.random(in: -0.28...0.28)
                animHeights[i] = min(1.0, max(0.12, base + jitter))
            }
        }
    }

    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
}

private struct VariantE_TypingDots: View {
    @State private var phase = 0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.primaryGreen)
                    .frame(width: 6, height: 6)
                    .scaleEffect(phase == i ? 1.3 : 0.8)
                    .opacity(phase == i ? 1 : 0.35)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.25)) {
                    phase = (phase + 1) % 3
                }
            }
        }
    }
}

// MARK: - Screen 7: Loading / Personalizing

private struct VariantE_LoadingScreen: View {
    let onDone: () -> Void

    @State private var progress: Double = 0
    @State private var stepIdx: Int = 0

    private let steps = [
        String(localized: "onboarding_e_loading_step_1"),
        String(localized: "onboarding_e_loading_step_2"),
        String(localized: "onboarding_e_loading_step_3"),
        String(localized: "onboarding_e_loading_step_4"),
    ]

    // Circle geometry
    private let radius: CGFloat = 70
    private var circumference: CGFloat { 2 * .pi * radius }

    var body: some View {
        ZStack {
            VariantE_BackgroundMesh()

            VStack(spacing: 0) {
                Spacer()

                // Circular progress ring
                ZStack {
                    // Track
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 4)
                        .frame(width: radius * 2, height: radius * 2)

                    // Progress arc
                    Circle()
                        .trim(from: 0, to: progress / 100)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "#5fff52"), Color.accentGreen],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: radius * 2, height: radius * 2)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: Color.primaryGreen.opacity(0.6), radius: 8)
                        .animation(.linear(duration: 0.1), value: progress)

                    // Center text
                    VStack(spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 1) {
                            Text("\(Int(progress))")
                                .font(.system(size: 38, weight: .heavy, design: .rounded))
                                .foregroundColor(.primaryText)
                                .monospacedDigit()
                            Text("%")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.secondaryText)
                        }
                        Text(String(localized: "onboarding_e_loading_label"))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.tertiaryText)
                            .kerning(0.4)
                            .textCase(.uppercase)
                    }
                }
                .frame(width: radius * 2, height: radius * 2)

                Spacer().frame(height: 36)

                Text(String(localized: "onboarding_e_loading_title"))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)

                Spacer().frame(height: 28)

                // Step rows
                VStack(spacing: 10) {
                    ForEach(steps.indices, id: \.self) { i in
                        HStack(spacing: 12) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(i < stepIdx
                                          ? Color.primaryGreen
                                          : (i == stepIdx ? Color.primaryGreen.opacity(0.18) : Color.white.opacity(0.04)))
                                    .frame(width: 26, height: 26)
                                    .overlay(
                                        Circle()
                                            .stroke(i == stepIdx ? Color.primaryGreen : Color.clear, lineWidth: 2)
                                    )

                                if i < stepIdx {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(Color(hex: "#062a04"))
                                } else if i == stepIdx {
                                    // Spinning indicator
                                    VariantE_SpinnerDot()
                                }
                            }

                            Text(steps[i])
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(i <= stepIdx ? .primaryText : .tertiaryText)
                                .animation(.easeInOut(duration: 0.3), value: stepIdx)

                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(i <= stepIdx ? Color.primaryGreen.opacity(0.06) : Color.clear)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(i <= stepIdx ? Color.primaryGreen.opacity(0.18) : Color.white.opacity(0.06), lineWidth: 1)
                        )
                        .animation(.easeInOut(duration: 0.3), value: stepIdx)
                    }
                }
                .padding(.horizontal, 28)

                Spacer()
            }
        }
        .onAppear { startProgress() }
    }

    private func startProgress() {
        // Tick every 35ms, +1.2% per tick ≈ ~3 seconds to 100
        Timer.scheduledTimer(withTimeInterval: 0.035, repeats: true) { timer in
            let next = progress + 1.2
            if next >= 100 {
                progress = 100
                stepIdx = steps.count - 1
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { onDone() }
            } else {
                progress = next
                stepIdx = min(steps.count - 1, Int(progress / 25))
            }
        }
    }
}

private struct VariantE_SpinnerDot: View {
    @State private var rotating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.75)
            .stroke(Color.primaryGreen, lineWidth: 2)
            .frame(width: 14, height: 14)
            .rotationEffect(.degrees(rotating ? 360 : 0))
            .onAppear {
                withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                    rotating = true
                }
            }
    }
}
