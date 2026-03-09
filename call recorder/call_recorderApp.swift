import SwiftUI
import RevenueCat
import RevenueCatUI

@main
struct call_recorderApp: App {
    @StateObject private var viewModel = AppViewModel.shared
    @StateObject private var subscriptionService = SubscriptionService.shared
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var showSplash = true
    @State private var isDataLoaded = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if viewModel.isOnboardingComplete {
                        ContentView()
                    } else if viewModel.showPhoneSelection {
                        PhoneSelectionView()
                    } else {
                        OnboardingEntryView()
                    }
                }
                .opacity(showSplash ? 0 : 1)
                .animation(.easeIn(duration: 0.5), value: showSplash)
                .fullScreenCover(isPresented: $subscriptionService.showPaywall) {
                    PaywallView(displayCloseButton: false)
                        .onPurchaseCompleted { customerInfo in
                            subscriptionService.checkSubscriptionStatus()
                            subscriptionService.showPaywall = false
                            if !viewModel.isRegistered {
                                withAnimation {
                                    viewModel.showPhoneSelection = true
                                }
                            }
                        }
                        .onRestoreCompleted { customerInfo in
                            subscriptionService.checkSubscriptionStatus()
                            subscriptionService.showPaywall = false
                            if !viewModel.isRegistered {
                                withAnimation {
                                    viewModel.showPhoneSelection = true
                                }
                            }
                        }
                }
                
                if showSplash {
                    SplashView(isDataLoaded: $isDataLoaded)
                        .transition(.opacity)
                        .zIndex(1)
                        .onChange(of: isDataLoaded) { loaded in
                            if loaded {
                                withAnimation {
                                    showSplash = false
                                }
                            }
                        }
                }
                
                if viewModel.showPhoneSelection {
                    PhoneSelectionView()
                        .transition(.opacity)
                        .zIndex(2)
                }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    Task {
                        await viewModel.fetchCallsFromServerAsync()
                    }
                }
            }
        }
    }
}
