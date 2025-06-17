import SwiftUI
import SuperwallKit

struct TranscriptEmptyState: View {
    let userType: AppViewModel.UserType
    let onUpgrade: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(minHeight: 40, maxHeight: 60)
            
            // Icon and Title Section
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
                    Text("No Transcripts Yet")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.primaryText)
                    
                    Text(userType == .free ? "Unlock the power of AI transcription" : "Your transcripts will appear here")
                        .font(.system(size: 14))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
            
            if userType == .free {
                // Features Section
                VStack(spacing: 14) {
                    TranscriptFeatureRow(
                        icon: "waveform.badge.mic",
                        title: "AI-Powered Transcriptions",
                        subtitle: "Convert calls to searchable text instantly"
                    )
                    
                    TranscriptFeatureRow(
                        icon: "magnifyingglass.circle.fill",
                        title: "Smart Search",
                        subtitle: "Find any conversation in seconds"
                    )
                    
                    TranscriptFeatureRow(
                        icon: "square.and.arrow.up.fill",
                        title: "Export & Share",
                        subtitle: "Save transcripts as text files"
                    )
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
                
                Spacer()
                    .frame(minHeight: 20, maxHeight: 40)
                
                // Upgrade Button
                VStack(spacing: 10) {
                    Button(action: {
                        Superwall.shared.register(placement: "campaign_trigger")
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 16))
                            Text("Upgrade to Premium")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.primaryGreen,
                                    Color.primaryGreen.opacity(0.85)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: Color.primaryGreen.opacity(0.25), radius: 10, x: 0, y: 4)
                    }
                    .padding(.horizontal, 28)
                    
                    Text("Start your 3-day free trial")
                        .font(.system(size: 12))
                        .foregroundColor(.tertiaryText)
                }
            } else {
                // Pro User Empty State
                Spacer()
                    .frame(minHeight: 30, maxHeight: 50)
                
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Image(systemName: "phone.arrow.up.right")
                            .font(.system(size: 26))
                            .foregroundColor(.primaryGreen)
                            .padding(14)
                            .background(
                                Circle()
                                    .fill(Color.primaryGreen.opacity(0.1))
                            )
                        
                        Text("Record your first call")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primaryText)
                        
                        Text("Transcripts will be generated automatically\nafter each recording")
                            .font(.system(size: 13))
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                    
                    HStack(spacing: 16) {
                        ProFeatureBadge(icon: "checkmark.seal.fill", text: "Premium Active")
                        ProFeatureBadge(icon: "infinity", text: "Unlimited Transcripts")
                    }
                }
            }
            
            Spacer()
                .frame(minHeight: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.darkBackground)
    }
}

struct TranscriptLoadingView: View {
    @State private var dots = ""
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.primaryGreen)
            
            Text("Generating transcript\(dots)")
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

