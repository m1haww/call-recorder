import SwiftUI

struct TranscriptEmptyState: View {
    let userType: AppViewModel.UserType
    let onUpgrade: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.primaryGreen.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.primaryGreen)
                }
                
                VStack(spacing: 12) {
                    Text("No Transcripts Yet")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryText)
                    
                    if userType == .free {
                        VStack(spacing: 20) {
                            Text("Upgrade to Premium to unlock")
                                .font(.subheadline)
                                .foregroundColor(.secondaryText)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.primaryGreen)
                                        .font(.system(size: 20))
                                    Text("AI-powered transcriptions")
                                        .font(.subheadline)
                                        .foregroundColor(.secondaryText)
                                    Spacer()
                                }
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.primaryGreen)
                                        .font(.system(size: 20))
                                    Text("Search within conversations")
                                        .font(.subheadline)
                                        .foregroundColor(.secondaryText)
                                    Spacer()
                                }
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.primaryGreen)
                                        .font(.system(size: 20))
                                    Text("Export transcripts to text")
                                        .font(.subheadline)
                                        .foregroundColor(.secondaryText)
                                    Spacer()
                                }
                            }
                            .frame(maxWidth: 280)
                        }
                        
                        Button(action: onUpgrade) {
                            HStack {
                                Image(systemName: "crown.fill")
                                Text("Upgrade to Premium")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.primaryGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .frame(minHeight: 44)
                        .padding(.horizontal, 40)
                        .padding(.top)
                    } else {
                        Text("Your call transcripts will appear here")
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                        
                        Text("Record a call to get started")
                            .font(.caption)
                            .foregroundColor(.secondaryText.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                }
            }
            
            Spacer()
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

#Preview {
    TranscriptEmptyState(userType: .free) {}
}