import SwiftUI
import Firebase
import FirebaseMessaging
import RevenueCat
import RevenueCatUI
import AppsFlyerLib
import AppTrackingTransparency

final class AppDelegate: NSObject, UIApplicationDelegate, AppsFlyerLibDelegate {
    
    // MARK: - AppsFlyer Configuration
    private let appsFlyerDevKey = "<YOUR_DEV_KEY>" // TODO: Replace with your AppsFlyer dev key
    private let appleAppID = "<APPLE_APP_ID>" // TODO: Replace with your Apple App ID
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        // Configure AppsFlyer
        AppsFlyerLib.shared().appsFlyerDevKey = appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = appleAppID
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().isDebug = false // Set to true for debugging
        
        // Enable TCF data collection for DMA compliance (optional - can be enabled via privacy manager)
        // AppsFlyerLib.shared().enableTCFDataCollection = true
        
        // Wait for ATT authorization before collecting IDFA
        if #available(iOS 14, *) {
            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        }
        
        // Configure push notification deep link path for AppsFlyer OneLink
        AppsFlyerLib.shared().addPushNotificationDeepLinkPath(["af_push_link"])
        
        // Set up notification observer for SceneDelegate support
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sendLaunch),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        Purchases.logLevel = .info
        Purchases.configure(withAPIKey: revenueCatApiKey)
        
        UNUserNotificationCenter.current().delegate = self
        
        Task {
            await handleNotificationPermissions(application: application)
        }
        
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            AppViewModel.shared.isProUser = customerInfo?.entitlements.all["Pro"]?.isActive == true
            
            // Set Customer User ID for AppsFlyer
            if let customerID = customerInfo?.originalAppUserId {
                AppsFlyerLib.shared().customerUserID = customerID
            }
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
    
    // MARK: - AppsFlyer Methods
    
    @objc private func sendLaunch() {
        // Use privacy manager to handle SDK start with consent
        AppsFlyerPrivacyManager.shared.initializeWithPrivacy()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Check if we need to request GDPR consent first
        if UserDefaults.standard.object(forKey: "appsflyer_subject_to_gdpr") == nil {
            // First time - check if GDPR consent is needed
            AppsFlyerPrivacyManager.shared.requestGDPRConsent { success in
                if success {
                    // GDPR consent handled, now start SDK with privacy settings
                    AppsFlyerPrivacyManager.shared.initializeWithPrivacy()
                }
            }
        } else {
            // GDPR consent already determined - start SDK with privacy settings
            AppsFlyerPrivacyManager.shared.initializeWithPrivacy()
        }
        
        // Request ATT authorization on iOS 14+
        if #available(iOS 14, *) {
            Task {
                await requestTrackingAuthorization()
            }
        }
    }
    
    @available(iOS 14, *)
    private func requestTrackingAuthorization() async {
        await ATTrackingManager.requestTrackingAuthorization()
    }
    
    // MARK: - AppsFlyerLibDelegate Methods
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        print("AppsFlyer: Conversion data received successfully")
        
        // Get attribution status
        if let status = conversionInfo["af_status"] as? String {
            print("AppsFlyer: Attribution status = \(status)")
            
            if status == "Non-organic" {
                // This is a non-organic install - user came from an ad campaign
                if let mediaSource = conversionInfo["media_source"] as? String {
                    print("AppsFlyer: Media source = \(mediaSource)")
                }
                if let campaign = conversionInfo["campaign"] as? String {
                    print("AppsFlyer: Campaign = \(campaign)")
                }
                if let adset = conversionInfo["adset"] as? String {
                    print("AppsFlyer: Adset = \(adset)")
                }
                
                // Track attribution data in your analytics
                AnalyticsManager.shared.logEvent("appsflyer_non_organic_install", parameters: [
                    "media_source": conversionInfo["media_source"] as? String ?? "unknown",
                    "campaign": conversionInfo["campaign"] as? String ?? "unknown"
                ])
                
            } else if status == "Organic" {
                // This is an organic install - user found the app naturally
                print("AppsFlyer: This is an organic install")
                
                AnalyticsManager.shared.logEvent("appsflyer_organic_install", parameters: [:])
            }
        }
        
        // Handle deep link data if present
        if let deepLinkValue = conversionInfo["deep_link_value"] as? String {
            print("AppsFlyer: Deep link value = \(deepLinkValue)")
            // Handle your deep link logic here
        }
        
        // Store conversion data for later use if needed
        UserDefaults.standard.set(conversionInfo, forKey: "AppsFlyerConversionData")
    }
    
    func onConversionDataFail(_ error: Error) {
        print("AppsFlyer: Failed to get conversion data")
        print("AppsFlyer Error: \(error.localizedDescription)")
        
        // Log error to analytics
        AnalyticsManager.shared.logEvent("appsflyer_conversion_data_fail", parameters: [
            "error": error.localizedDescription
        ])
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
        let userInfo = notification.request.content.userInfo
        print("Push notification received (foreground): \(userInfo)")
        
        // Handle AppsFlyer push notification tracking
        AppsFlyerLib.shared().handlePushNotification(userInfo)
        
        return [[.badge, .sound]]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        print("Push notification tapped: \(userInfo)")
        
        // Handle AppsFlyer push notification tracking
        AppsFlyerLib.shared().handlePushNotification(userInfo)
        
        // Track push notification opened event
        AppsFlyerLib.shared().logEvent(AFEventOpenedFromPushNotification, withValues: [
            AFEventParamContentType: "push_notification",
            AFEventParam1: userInfo["aps"] != nil ? "apns" : "fcm"
        ])
        
        // Handle your app-specific push notification logic here
        // Example: Navigate to specific content based on notification payload
        if let deepLink = userInfo["af_push_link"] as? String {
            print("AppsFlyer OneLink detected: \(deepLink)")
            // Handle OneLink navigation
        }
        
        // Try to decode as Recording for navigation
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: userInfo)
            let recording = try JSONDecoder().decode(Recording.self, from: jsonData)
            
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            AppViewModel.shared.navigateTo(.callDetails(recording))
        } catch {
            print("Can't decode userInfo: \(error)")
        }
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
