import SwiftUI

struct SplashView: View {
    @ObservedObject var viewModel = AppViewModel.shared
    
    @State private var isAnimating = false
    @State private var showLogo = false
    @State private var showAppName = false
    @State private var showTagline = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.skyBlue.opacity(0.8), Color.navyBlue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 150, height: 150)
                        .scaleEffect(isAnimating ? 1.1 : 0.9)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(0.2), value: isAnimating)
                    
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .scaleEffect(showLogo ? 1.0 : 0)
                        .opacity(showLogo ? 1.0 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: showLogo)
                }
                
                VStack(spacing: 16) {
                    Text("Call Recorder")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(showAppName ? 1.0 : 0)
                        .offset(y: showAppName ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.3), value: showAppName)
                    
                    Text("Record & Transcribe Your Calls")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .opacity(showTagline ? 1.0 : 0)
                        .offset(y: showTagline ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.6), value: showTagline)
                }
                
                Spacer()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                    .opacity(showTagline ? 1.0 : 0)
                    .animation(.easeIn(duration: 0.5).delay(0.8), value: showTagline)
                    .padding(.bottom, 60)
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
                showLogo = true
                showAppName = true
                showTagline = true
            }
            
            viewModel.fetchCallsFromServer()
        }
    }
}
