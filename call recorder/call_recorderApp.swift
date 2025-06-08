//
//  call_recorderApp.swift
//  call recorder
//
//  Created by Mihail Ozun on 05.06.2025.
//

import SwiftUI

@main
struct call_recorderApp: App {
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .opacity(showSplash ? 0 : 1)
                    .animation(.easeIn(duration: 0.5), value: showSplash)
                
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                withAnimation {
                                    showSplash = false
                                }
                            }
                        }
                }
            }
        }
    }
}
