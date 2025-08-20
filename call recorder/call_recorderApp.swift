import SwiftUI
import Firebase
import FirebaseMessaging
import RevenueCat
import RevenueCatUI
import AdSupport
import AppTrackingTransparency
import AppsFlyerLib

final class AppDelegate: NSObject, UIApplicationDelegate, AppsFlyerLibDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        Purchases.logLevel = .info
        Purchases.configure(withAPIKey: revenueCatApiKey)
        
        UNUserNotificationCenter.current().delegate = self
        
        initializeAppsFlyer()
        
        Task {
            await handleNotificationPermissions(application: application)
        }
        
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            AppViewModel.shared.isProUser = customerInfo?.entitlements.all["Main"]?.isActive == true
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
    }
    
    private func initializeAppsFlyer() {
        AppsFlyerLib.shared().appsFlyerDevKey = "dKn4FEE9piNWsgvBgVGuAb"
        AppsFlyerLib.shared().appleAppID = "6746982805"
        
        AppsFlyerLib.shared().isDebug = true
        
        AppsFlyerLib.shared().delegate = self
        
        AppsFlyerLib.shared().addPushNotificationDeepLinkPath(["af_push_link"])
        
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(sendLaunch), name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
    
    @objc private func sendLaunch() {
        AppsFlyerLib.shared().start()
        
        Task { @MainActor in
            await requestATTPermission()
        }
    }
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        if let status = conversionInfo["af_status"] as? String {
            if status == "Non-organic" {
                let mediaSource = conversionInfo["media_source"] as? String ?? "Unknown"
                let campaign = conversionInfo["campaign"] as? String ?? "Unknown"
                print("Non-organic install. Media source: \(mediaSource), Campaign: \(campaign)")
            } else if status == "Organic" {
                print("Organic install")
            }
        }
        
        print("Conversion Data: \(conversionInfo)")
    }
    
    func onConversionDataFail(_ error: any Error) {
        print("Error getting conversion data: \(error.localizedDescription)")
    }
    
    func application(
        _ application: UIApplication, continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        return true
    }
    
    func application(
        _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return true
    }
}

@main
struct call_recorderApp: App {
    @ObservedObject private var viewModel = AppViewModel.shared
    
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var showSplash = true
    @State private var isDataLoaded = false
    
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
                        .onPurchaseCompleted { customerInfo in
                            viewModel.isProUser = true
                            viewModel.showPaywall = false
                            
                            if let productId = customerInfo.activeSubscriptions.first,
                               let entitlement = customerInfo.entitlements.all["Pro"],
                               entitlement.isActive {
                                
                                let isInTrialPeriod = entitlement.periodType == .trial
                                
                                Purchases.shared.getOfferings { (offerings, error) in
                                    var price: Double = 9.99
                                    var currency = "USD"
                                    
                                    if let packages = offerings?.current?.availablePackages {
                                        for package in packages {
                                            if package.storeProduct.productIdentifier == productId {
                                                price = Double(truncating: package.storeProduct.price as NSNumber)
                                                currency = package.storeProduct.currencyCode ?? "USD"
                                                break
                                            }
                                        }
                                    }
                                    
                                    let revenue = isInTrialPeriod ? 0.0 : price
                                    
                                    var eventParams: [String: Any] = [
                                        AFEventParamContentId: productId,
                                        AFEventParamContentType: "subscription",
                                        AFEventParamCurrency: currency,
                                        AFEventParamRevenue: revenue,
                                        AFEventParamPrice: price,
                                        AFEventParamQuantity: 1
                                    ]
                                    
                                    if let purchaseDate = entitlement.originalPurchaseDate {
                                        eventParams[AFEventParamEventStart] = purchaseDate
                                    }
                                    
                                    if isInTrialPeriod {
                                        eventParams["is_trial"] = true
                                        eventParams["trial_start_date"] = entitlement.originalPurchaseDate
                                        
                                        AppsFlyerLib.shared().logEvent("af_start_trial", withValues: [
                                            AFEventParamContentId: productId,
                                            AFEventParamContentType: "subscription_trial",
                                            AFEventParamRevenue: 0.0,
                                            AFEventParamPrice: price,
                                            AFEventParamCurrency: currency,
                                            "trial_start_date": entitlement.originalPurchaseDate ?? Date()
                                        ])
                                    }
                                    
                                    AppsFlyerLib.shared().logEvent(AFEventPurchase, withValues: eventParams)
                                    
                                    let subscriptionType = isInTrialPeriod ? "premium_subscription_trial" : "premium_subscription"
                                    
                                    AppsFlyerLib.shared().logEvent(AFEventSubscribe, withValues: [
                                        AFEventParamContentId: productId,
                                        AFEventParamContentType: subscriptionType,
                                        AFEventParamRevenue: revenue,
                                        AFEventParamPrice: price,
                                        AFEventParamCurrency: currency,
                                        "is_trial": isInTrialPeriod
                                    ])
                                }
                            }
                        }
                        .onRestoreCompleted { customerInfo in
                            viewModel.isProUser = customerInfo.entitlements.all["Main"]?.isActive == true
                            viewModel.showPaywall = false
                        }
                        .onPurchaseStarted { _ in
                            AppsFlyerLib.shared().logEvent("paywall_purchase_started", withValues: [
                                "paywall_type": "apple_pay_dialog",
                                "timestamp": Date().timeIntervalSince1970
                            ])
                        }
                }
                
                if showSplash {
                    SplashView(isDataLoaded: $isDataLoaded)
                        .transition(.opacity)
                        .zIndex(1)
                        .onChange(of: isDataLoaded) { loaded in
                            if loaded {
                                withAnimation {
                                    showSplash = false
                                }
                            }
                        }
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                // No need to call applicationDidBecomeActive here as NotificationCenter handles it
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
