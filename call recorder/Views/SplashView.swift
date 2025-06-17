import SwiftUI

struct SplashView: View {
    @ObservedObject var viewModel = AppViewModel.shared
    @State private var fetchTask: Task<Void, Never>?
    
    var body: some View {
        ZStack {
            Color.darkBackground
                .ignoresSafeArea()
            
            Image("icon")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            
            VStack {
                Spacer()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primaryGreen))
                    .scaleEffect(1.0)
                    .padding(.bottom, 80)
            }
        }
        .onAppear {
            AnalyticsManager.shared.logEvent(name: "App Launched")
            
            fetchTask = Task {
                await viewModel.fetchCallsFromServerAsync()
            }
        }
        .onDisappear {
            fetchTask?.cancel()
        }
    }
}
