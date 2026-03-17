import SwiftUI

struct TranscriptEmptyState: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    let isProUser: Bool
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(minHeight: 120, maxHeight: 160)
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.primaryGreen.opacity(0.08))
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .fill(Color.primaryGreen.opacity(0.12))
                        .frame(width: 90, height: 90)
                    
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundColor(.primaryGreen)
                        .symbolRenderingMode(.hierarchical)
                }
                
                VStack(spacing: 6) {
                    Text(localizationManager.localizedString("no_transcripts"))
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.primaryText)
                    
                    Text(localizationManager.localizedString("transcripts_first_recording_hint"))
                        .font(.system(size: 14))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity)
            }
            
            Spacer()
                .frame(minHeight: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.darkBackground)
    }
}

struct TranscriptLoadingView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var dots = ""
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.primaryGreen)
            
            Text(localizationManager.localizedString("generating_transcript") + dots)
                .font(.subheadline)
                .foregroundColor(.primaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.6))
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            withAnimation {
                if dots.count < 3 {
                    dots += "."
                } else {
                    dots = ""
                }
            }
        }
    }
}

struct TranscriptFeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.primaryGreen)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.primaryGreen.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primaryText)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondaryText)
                    .lineLimit(1)
            }
            
            Spacer()
        }
    }
}

struct ProFeatureBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
            Text(text)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(.primaryGreen)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.primaryGreen.opacity(0.1))
        )
    }
}

