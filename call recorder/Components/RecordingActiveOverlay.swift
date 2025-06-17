import SwiftUI

struct RecordingActiveOverlay: View {
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .scaleEffect(pulseAnimation ? 1.2 : 0.8)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulseAnimation)
                    
                    Text("Recording")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 4)
                .padding(.trailing)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .onAppear {
            pulseAnimation = true
        }
    }
}
