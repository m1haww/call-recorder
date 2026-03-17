import SwiftUI
import Firebase
import FirebaseMessaging
import RevenueCat
import RevenueCatUI
import AdSupport
import AppTrackingTransparency
import FirebaseAnalytics

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        OnboardingRemoteConfigManager.shared.fetchAndActivate()
        
        Purchases.logLevel = .info
        Purchases.configure(withAPIKey: revenueCatApiKey, appUserID: AppViewModel.shared.userId)
        
        if ATTrackingManager.trackingAuthorizationStatus != .notDetermined {
            Task {
                await setAppleSearchAdsAttribution()
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        SubscriptionService.shared.checkSubscriptionStatus()
        
        let instanceID = Analytics.appInstanceID()
        if let unwrapped = instanceID {
            Purchases.shared.attribution.setFirebaseAppInstanceID(unwrapped)
        }
        
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

        await setAppleSearchAdsAttribution()
    }

    private static let hasSetAppleSearchAdsAttributionKey = "hasSetAppleSearchAdsAttributionToRevenueCat"

    @MainActor
    private func setAppleSearchAdsAttribution() async {
        guard #available(iOS 14.3, *) else { return }
        guard !UserDefaults.standard.bool(forKey: Self.hasSetAppleSearchAdsAttributionKey) else { return }
        UserDefaults.standard.set(true, forKey: Self.hasSetAppleSearchAdsAttributionKey)

        guard let data = await AppleAttributionManager.shared.fetchAttributionData() else { return }
        guard data.attribution else { return }
        setRevenuecatAttributes(data: data)
    }

    private func setRevenuecatAttributes(data: AppleAttributionData) {
        Purchases.shared.attribution.setKeyword(data.keywordId.map { String($0) })
        Purchases.shared.attribution.setAdGroup(data.adGroupId.map { String($0) })
        Purchases.shared.attribution.setCampaign(data.campaignId.map { String($0) })
        Purchases.shared.attribution.setAttributes(["installDate": data.clickDate ?? Self.getCurrentDate()])
        Purchases.shared.attribution.setMediaSource("Apple Search Ads")
        Purchases.shared.attribution.setAd(data.adId.map { String($0) })
    }

    private static func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
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

