import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "waveform.circle")
                .font(.system(size: 80))
                .foregroundColor(.darkGrey)
            
            VStack(spacing: 8) {
                Text("No Recordings Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.navyBlue)
                
                Text("Start recording calls to see them here")
                    .font(.subheadline)
                    .foregroundColor(.darkGrey)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.lightGrey)
    }
}

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.skyBlue, lineWidth: 3)
                .frame(width: 40, height: 40)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            
            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(.darkGrey)
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

#Preview {
    EmptyStateView()
}