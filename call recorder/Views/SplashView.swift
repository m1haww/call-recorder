import SwiftUI

struct SplashView: View {
    @ObservedObject var viewModel = AppViewModel.shared
    @State private var fetchTask: Task<Void, Never>?
    
    var body: some View {
        ZStack {
            Color.darkBackground
            
            Image("icon")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 17))
            
            VStack {
                Spacer()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primaryGreen))
                    .scaleEffect(1.0)
                    .padding(.bottom, 80)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            AnalyticsManager.shared.logEvent(name: "App Launched")
            
            fetchTask = Task {
                await withTaskGroup(of: Void.self) { group in
                    group.addTask {
                        await viewModel.loadUserDataFromServer()
                    }
                    
                    group.addTask {
                        await viewModel.fetchCallsFromServerAsync()
                    }
                    
                    group.addTask {
                        await viewModel.fetchPhoneServiceNumber()
                    }
                }
            }
        }
        .onDisappear {
            fetchTask?.cancel()
        }
    }
}
