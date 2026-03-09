import SwiftUI

struct ContentView: View {
    @StateObject private var appManager = AppViewModel.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var viewModel = ContentViewModel()
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    @State private var showToast = false
    
    private func navigationTitleForTab(_ tabIndex: Int) -> String {
        switch tabIndex {
        case 0: return localizationManager.localizedString("recordings")
        case 1: return localizationManager.localizedString("record_call")
        case 2: return localizationManager.localizedString("transcripts")
        case 3: return localizationManager.localizedString("settings")
        default: return localizationManager.localizedString("recordings")
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.darkBackground)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    private func makePhoneCall(to number: String) {
        let phoneNumber = "tel://\(number)"
        if let url = URL(string: phoneNumber), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            appManager.showToast("Unable to make phone call")
        }
    }
    
    var body: some View {
        NavigationStack(path: $appManager.navigationPath) {
            ZStack {
                TabView(selection: $viewModel.selectedTab) {
                    HomeView(navigationPath: $appManager.navigationPath)
                        .tabItem {
                            Label(localized("recordings"), systemImage: viewModel.selectedTab == 0 ? "house.fill" : "house")
                        }
                        .tag(0)
                    
                    RecordCallView()
                        .tabItem {
                            Label(localized("record_call"), systemImage: viewModel.selectedTab == 1 ? "phone.circle.fill" : "phone.circle")
                        }
                        .tag(1)
                    
                    TranscriptsView(navigationPath: $appManager.navigationPath)
                        .tabItem {
                            Label(localized("transcripts"), systemImage: viewModel.selectedTab == 2 ? "doc.text.fill" : "doc.text")
                        }
                        .tag(2)
                    
                    SettingsView()
                        .tabItem {
                            Label(localized("settings"), systemImage: viewModel.selectedTab == 3 ? "gearshape.fill" : "gearshape")
                        }
                        .tag(3)
                }
                .tint(.primaryGreen)
                .preferredColorScheme(.dark)
                .onAppear {
                    configureTabBarAppearance()
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            HapticManager.shared.impact(.medium)
                            if appManager.recordingServiceNumber.isEmpty {
                                appManager.showToast("Loading service number...")
                            } else if subscriptionService.isProUser {
                                makePhoneCall(to: appManager.recordingServiceNumber)
                            } else {
                                subscriptionService.showPaywall = true
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.primaryGreen)
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .shadow(color: Color.primaryGreen.opacity(0.4), radius: 8, x: 0, y: 4)
                        .padding(.trailing, 20)
                        .padding(.bottom, 70)
                    }
                }
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .callDetails(let recording):
                        CallDetailsView(recording: recording, navigationPath: $appManager.navigationPath)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar(.hidden, for: .tabBar)
                    case .transcripts:
                        TranscriptsView(navigationPath: $appManager.navigationPath)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar(.hidden, for: .tabBar)
                    case .transcriptDetail(let recording):
                        TranscriptDetailView(recording: recording)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar(.hidden, for: .tabBar)
                    case .settings:
                        SettingsView()
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar(.hidden, for: .tabBar)
                    case .recordCall:
                        RecordCallView()
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar(.hidden, for: .tabBar)
                    case .player(let recording):
                        RecordingPlayerView(recording: recording)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar(.hidden, for: .tabBar)
                    }
                }
            }
            .navigationTitle(navigationTitleForTab(viewModel.selectedTab))
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.darkBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toast(message: appManager.alertMessage, isShowing: $showToast)
            .onChange(of: appManager.showAlert) { newValue in
                if newValue {
                    showToast = true
                    appManager.showAlert = false
                }
            }
        }
    }
}
