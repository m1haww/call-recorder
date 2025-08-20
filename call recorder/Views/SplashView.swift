import SwiftUI

struct SplashView: View {
    @ObservedObject var viewModel = AppViewModel.shared
    @State private var fetchTask: Task<Void, Never>?
    @Binding var isDataLoaded: Bool
    @State private var minimumTimeElapsed = false
    @State private var dataLoadingComplete = false
    
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                minimumTimeElapsed = true
                checkIfReadyToNavigate()
            }
            
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
                
                await MainActor.run {
                    dataLoadingComplete = true
                    checkIfReadyToNavigate()
                }
            }
        }
        .onDisappear {
            fetchTask?.cancel()
        }
    }
    
    private func checkIfReadyToNavigate() {
        if minimumTimeElapsed && dataLoadingComplete {
            isDataLoaded = true
        }
    }
}
