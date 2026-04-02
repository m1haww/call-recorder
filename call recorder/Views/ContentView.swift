import SwiftUI

struct ContentView: View {
    @StateObject private var appManager = AppViewModel.shared
    @StateObject private var viewModel = ContentViewModel()
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    @State private var showToast = false
    @State private var showRecordCallTutorial = false

    private func navigationTitleForTab(_ tabIndex: Int) -> String {
        switch tabIndex {
        case 0: return String(localized: "Recordings")
        case 1: return String(localized: "Record Call")
        case 2: return String(localized: "Transcripts")
        case 3: return String(localized: "Settings")
        default: return String(localized: "Recordings")
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
            appManager.showToast(String(localized: "Unable to make phone call on this device"))
        }
    }
    
    var body: some View {
        NavigationStack(path: $appManager.navigationPath) {
            ZStack {
                TabView(selection: $viewModel.selectedTab) {
                    HomeView(navigationPath: $appManager.navigationPath)
                        .tabItem {
                            Label(String(localized: "Recordings"), systemImage: viewModel.selectedTab == 0 ? "house.fill" : "house")
                        }
                        .tag(0)
                    
                    RecordCallView()
                        .tabItem {
                            Label(String(localized: "Record Call"), systemImage: viewModel.selectedTab == 1 ? "phone.circle.fill" : "phone.circle")
                        }
                        .tag(1)
                    
                    TranscriptsView(navigationPath: $appManager.navigationPath)
                        .tabItem {
                            Label(String(localized: "Transcripts"), systemImage: viewModel.selectedTab == 2 ? "doc.text.fill" : "doc.text")
                        }
                        .tag(2)
                    
                    SettingsView()
                        .tabItem {
                            Label(String(localized: "Settings"), systemImage: viewModel.selectedTab == 3 ? "gearshape.fill" : "gearshape")
                        }
                        .tag(3)
                }
                .tint(.primaryGreen)
                .preferredColorScheme(.dark)
                .onAppear {
                    configureTabBarAppearance()
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
                
                if viewModel.selectedTab != 1 && viewModel.selectedTab != 3 {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                HapticManager.shared.impact(.medium)
                                if appManager.recordingServiceNumber.isEmpty {
                                    appManager.showToast(String(localized: "Loading service number..."))
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
                }
            }
            .navigationTitle(navigationTitleForTab(viewModel.selectedTab))
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.darkBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        HapticManager.shared.selection()
                        showRecordCallTutorial = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.title3)
                            .foregroundColor(.primaryText)
                    }
                }
            }
            .sheet(isPresented: $showRecordCallTutorial) {
                RecordCallTutorialView()
            }
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
