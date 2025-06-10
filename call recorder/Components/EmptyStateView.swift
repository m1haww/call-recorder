import SwiftUI

struct EmptyStateView: View {
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "waveform.circle")
                .font(.system(size: 80))
                .foregroundColor(.secondaryText)
            
            VStack(spacing: 8) {
                Text("No Recordings Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                
                Text("Your recorded calls will appear here")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                
                Text("Tap the Record Call tab to get started")
                    .font(.caption)
                    .foregroundColor(.secondaryText.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.darkBackground)
    }
}

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.primaryGreen, lineWidth: 3)
                .frame(width: 40, height: 40)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            
            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
        .onAppear {
            isAnimating = true
        }
    }
}

struct RefreshControl: View {
    let action: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if geometry.frame(in: .global).minY > 100 {
                    ProgressView()
                        .scaleEffect(0.8)
                        .onAppear {
                            action()
                        }
                }
            }
        }
        .frame(height: 0)
    }
}
