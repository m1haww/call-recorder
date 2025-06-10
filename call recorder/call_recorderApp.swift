import SwiftUI

@main
struct call_recorderApp: App {
    @ObservedObject private var viewModel = AppViewModel.shared
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if viewModel.isOnboardingComplete {
                        ContentView()
                    } else {
                        OnboardingView()
                    }
                }
                .opacity(showSplash ? 0 : 1)
                .animation(.easeIn(duration: 0.5), value: showSplash)
                
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                withAnimation {
                                    showSplash = false
                                }
                            }
                        }
                }
            }
        }
    }
}
