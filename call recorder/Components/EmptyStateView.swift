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
