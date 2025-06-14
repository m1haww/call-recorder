import SwiftUI

struct ContentView: View {
    @ObservedObject private var appManager = AppViewModel.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @StateObject private var viewModel = ContentViewModel()
    
    @State private var showToast = false
    @State private var navigationPath = NavigationPath()
    
    private func makePhoneCall(to number: String) {
        let phoneNumber = "tel://\(number)"
        if let url = URL(string: phoneNumber), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            appManager.showToast("Unable to make phone call")
        }
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                TabView(selection: $viewModel.selectedTab) {
                    HomeView(navigationPath: $navigationPath)
                        .tabItem {
                            Label(localized("recordings"), systemImage: viewModel.selectedTab == 0 ? "house.fill" : "house")
                        }
                        .tag(0)
                    
                    RecordCallView()
                        .tabItem {
                            Label(localized("record_call"), systemImage: viewModel.selectedTab == 1 ? "phone.circle.fill" : "phone.circle")
                        }
                        .tag(1)
                    
                    TranscriptsView(navigationPath: $navigationPath)
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
                    let appearance = UITabBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = UIColor(Color.darkBackground)
                    
                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            HapticManager.shared.impact(.medium)
                            makePhoneCall(to: appManager.recordingServiceNumber)
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
                        .padding(.bottom, 90)
                    }
                }
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .callDetails(let recording):
                        CallDetailsView(recording: recording)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar(.hidden, for: .tabBar)
                    case .transcripts:
                        TranscriptsView(navigationPath: $navigationPath)
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
            .toast(message: appManager.alertMessage, isShowing: $showToast)
            .onChange(of: appManager.showAlert) { newValue in
                if newValue {
                    showToast = true
                    appManager.showAlert = false
                }
            }
            .alert("Permission Required", isPresented: $appManager.showPermissionAlert) {
                Button("Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(appManager.permissionType == .microphone ?
                     "Microphone access is required to record calls. Please enable it in Settings." :
                        "Phone access is required to make calls. Please enable it in Settings.")
            }
        }
    }
}
