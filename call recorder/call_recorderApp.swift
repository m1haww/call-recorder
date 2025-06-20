import SwiftUI
import Firebase
import FirebaseMessaging
import RevenueCat
import RevenueCatUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        Purchases.logLevel = .info
        Purchases.configure(withAPIKey: revenueCatApiKey)
        
        UNUserNotificationCenter.current().delegate = self
        
        Task {
            await handleNotificationPermissions(application: application)
        }
        
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            AppViewModel.shared.isProUser = customerInfo?.entitlements.all["Pro"]?.isActive == true
        }
        
        return true
    }
    
    @MainActor
    private func handleNotificationPermissions(application: UIApplication) async {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)
            print("Notification authorization granted: \(granted)")
        } catch {
            print("Notification authorization error: \(error.localizedDescription)")
        }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
    }
}

@main
struct call_recorderApp: App {
    @ObservedObject private var viewModel = AppViewModel.shared
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if viewModel.isOnboardingComplete {
                        ContentView()
                    } else {
                        OnboardingView()
                    }
                }
                .opacity(showSplash ? 0 : 1)
                .animation(.easeIn(duration: 0.5), value: showSplash)
                .fullScreenCover(isPresented: $viewModel.showPaywall) {
                    PaywallView(displayCloseButton: false)
                        .onPurchaseCompleted { _ in
                            viewModel.isProUser = true
                            viewModel.showPaywall = false
                        }
                        .onRestoreCompleted { _ in
                            viewModel.isProUser = true
                            viewModel.showPaywall = false
                        }
                }
                
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                withAnimation {
                                    showSplash = false
                                }
                                
                                if viewModel.isOnboardingComplete && !viewModel.isProUser {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        viewModel.showPaywall = true
                                    }
                                }
                            }
                        }
                }
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        return [[.badge, .sound]]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        print(userInfo)
        
        //        guard let jobId = userInfo["jobId"] as? String,
        //              let stringType = userInfo["type"] as? String,
        //              let type = GenerationType(rawValue: stringType.lowercased()) else {
        //            print("❌ Invalid or missing data in notification payload.")
        //            return
        //        }
        //
        //        try? await Task.sleep(nanoseconds: 500_000_000)
        //
        //        GlobalState.shared.navigationPath.append(.imageFilter(jobId: jobId, type: type))
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            print("No FCM token received")
            return
        }
        
        UserService.shared.saveFCMToken(fcmToken)
        
        let dataDict: [String: String] = ["token": fcmToken]
        
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}
