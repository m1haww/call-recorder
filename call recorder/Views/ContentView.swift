import SwiftUI

struct ContentView: View {
    @StateObject private var appManager = AppViewModel()
    @StateObject private var viewModel = ContentViewModel()
    
    @State private var showToast = false
    
    private func makePhoneCall() {
        let phoneNumber = "tel://+15205935701"
        if let url = URL(string: phoneNumber), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            appManager.showToast("Unable to make phone call")
        }
    }
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: viewModel.selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)
            
            RecordCallView()
                .tabItem {
                    Label("Record Call", systemImage: viewModel.selectedTab == 1 ? "phone.circle.fill" : "phone.circle")
                }
                .tag(1)
            
            TranscriptsView()
                .tabItem {
                    Label("Transcripts", systemImage: viewModel.selectedTab == 2 ? "doc.text.fill" : "doc.text")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: viewModel.selectedTab == 3 ? "gearshape.fill" : "gearshape")
                }
                .tag(3)
        }
        .tint(.skyBlue)
        .environmentObject(appManager)
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
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                HapticManager.shared.impact(.medium)
                makePhoneCall()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.skyBlue)
                        .frame(width: 60, height: 60)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "phone.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 90)
        }
    }
}
