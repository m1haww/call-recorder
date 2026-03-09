import SwiftUI
import Firebase
import FirebaseMessaging
import RevenueCat
import RevenueCatUI
import AdSupport
import AppTrackingTransparency

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        OnboardingRemoteConfigManager.shared.fetchAndActivate()

        Purchases.logLevel = .info
        Purchases.configure(withAPIKey: revenueCatApiKey, appUserID: AppViewModel.shared.userId)
        
        if ATTrackingManager.trackingAuthorizationStatus != .notDetermined {
            Purchases.shared.attribution.enableAdServicesAttributionTokenCollection()
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        SubscriptionService.shared.checkSubscriptionStatus()
        
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await requestATTPermission()
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await handleNotificationPermissions(application: application)
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
    
    @MainActor
    private func requestATTPermission() async {
        guard #available(iOS 14, *) else { return }
        
        let status = await ATTrackingManager.requestTrackingAuthorization()
        switch status {
        case .authorized:
            print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
        case .denied:
            print("ATT permission denied")
        case .restricted:
            print("ATT permission restricted")
        case .notDetermined:
            print("ATT permission still not determined")
        @unknown default:
            print("Unknown ATT status")
        }
        
        Purchases.shared.attribution.enableAdServicesAttributionTokenCollection()
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
        
        AppViewModel.shared.saveFCMToken(fcmToken)
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

