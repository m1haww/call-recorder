import SwiftUI

struct SplashView: View {
    @StateObject var viewModel = AppViewModel.shared
    @Binding var isDataLoaded: Bool
    
    var body: some View {
        ZStack {
            Color.darkBackground
            
            Image("icon")
                .resizable()
                .scaledToFit()
                .frame(width: 137.5, height: 137.5)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            VStack {
                Spacer()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primaryGreen))
                    .scaleEffect(1.0)
                    .padding(.bottom, 80)
            }
        }
        .ignoresSafeArea()
        .task {
            AnalyticsManager.shared.logEvent(name: "App Launched")
            
            await OnboardingRemoteConfigManager.shared.fetchAndActivateConfig()
            
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            await viewModel.loadUserDataFromServer()
            await viewModel.fetchCallsFromServerAsync()
            await viewModel.fetchPhoneServiceNumber()
            
            self.isDataLoaded = true
        }
    }
}
