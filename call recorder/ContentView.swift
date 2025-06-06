//
//  ContentView.swift
//  call recorder
//
//  Created by Mihail Ozun on 05.06.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppViewModel()
    @State private var selectedTab = 0
    @State private var showToast = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)
            
            RecordCallView()
                .tabItem {
                    Label("Record Call", systemImage: selectedTab == 1 ? "phone.circle.fill" : "phone.circle")
                }
                .tag(1)
            
            TranscriptsView()
                .tabItem {
                    Label("Transcripts", systemImage: selectedTab == 2 ? "doc.text.fill" : "doc.text")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: selectedTab == 3 ? "gearshape.fill" : "gearshape")
                }
                .tag(3)
        }
        .tint(.skyBlue)
        .environmentObject(viewModel)
        .toast(message: viewModel.alertMessage, isShowing: $showToast)
        .onChange(of: viewModel.showAlert) { newValue in
            if newValue {
                showToast = true
                viewModel.showAlert = false
            }
        }
        .alert("Permission Required", isPresented: $viewModel.showPermissionAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(viewModel.permissionType == .microphone ? 
                 "Microphone access is required to record calls. Please enable it in Settings." :
                 "Phone access is required to make calls. Please enable it in Settings.")
        }
        .onTapGesture {
            HapticManager.shared.selection()
        }
    }
}

#Preview {
    ContentView()
}
