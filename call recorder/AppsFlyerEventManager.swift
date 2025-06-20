import Foundation
import AppsFlyerLib

final class AppsFlyerEventManager {
    
    static let shared = AppsFlyerEventManager()
    
    private init() {}
    
    // MARK: - Purchase Events
    
    func logPurchase(productId: String, revenue: Double, currency: String = "USD", transactionId: String? = nil) {
        var parameters: [String: Any] = [
            AFEventParamContentId: productId,
            AFEventParamRevenue: revenue,
            AFEventParamCurrency: currency,
            AFEventParamContentType: "subscription"
        ]
        
        if let transactionId = transactionId {
            parameters[AFEventParamReceiptId] = transactionId
        }
        
        logEvent(name: AFEventPurchase, parameters: parameters)
    }
    
    func logSubscriptionStarted(productId: String, price: Double, currency: String = "USD") {
        let parameters: [String: Any] = [
            AFEventParamContentId: productId,
            AFEventParamPrice: price,
            AFEventParamCurrency: currency,
            AFEventParamContentType: "subscription"
        ]
        
        logEvent(name: AFEventStartTrial, parameters: parameters)
    }
    
    func logSubscriptionRenewed(productId: String, revenue: Double, currency: String = "USD") {
        let parameters: [String: Any] = [
            AFEventParamContentId: productId,
            AFEventParamRevenue: revenue,
            AFEventParamCurrency: currency,
            AFEventParamContentType: "subscription_renewal"
        ]
        
        logEvent(name: AFEventSubscribe, parameters: parameters)
    }
    
    // MARK: - Recording Events
    
    func logRecordingStarted() {
        let parameters: [String: Any] = [
            AFEventParamContentType: "recording",
            AFEventParam1: "recording_started"
        ]
        
        logEvent(name: "recording_started", parameters: parameters)
    }
    
    func logRecordingCompleted(duration: TimeInterval, transcribed: Bool = false) {
        let parameters: [String: Any] = [
            AFEventParamContentType: "recording",
            AFEventParam1: "recording_completed",
            AFEventParam2: "\(Int(duration))",
            AFEventParam3: transcribed ? "transcribed" : "not_transcribed"
        ]
        
        logEvent(name: AFEventAchievementUnlocked, parameters: parameters)
    }
    
    func logTranscriptionStarted() {
        let parameters: [String: Any] = [
            AFEventParamContentType: "transcription",
            AFEventParam1: "transcription_started"
        ]
        
        logEvent(name: "transcription_started", parameters: parameters)
    }
    
    func logTranscriptionCompleted(wordCount: Int, duration: TimeInterval) {
        let parameters: [String: Any] = [
            AFEventParamContentType: "transcription",
            AFEventParam1: "transcription_completed",
            AFEventParam2: "\(wordCount)",
            AFEventParam3: "\(Int(duration))"
        ]
        
        logEvent(name: AFEventContentView, parameters: parameters)
    }
    
    // MARK: - User Journey Events
    
    func logOnboardingStarted() {
        logEvent(name: "onboarding_started", parameters: [:])
    }
    
    func logOnboardingCompleted() {
        logEvent(name: AFEventCompleteRegistration, parameters: [
            AFEventParamRegistrationMethod: "onboarding_flow"
        ])
    }
    
    func logOnboardingSkipped() {
        logEvent(name: "onboarding_skipped", parameters: [:])
    }
    
    func logLogin(method: String = "automatic") {
        logEvent(name: AFEventLogin, parameters: [
            AFEventParamRegistrationMethod: method
        ])
    }
    
    func logPaywallViewed(source: String) {
        let parameters: [String: Any] = [
            AFEventParamContentType: "paywall",
            AFEventParam1: source
        ]
        
        logEvent(name: AFEventContentView, parameters: parameters)
    }
    
    func logPaywallDismissed(source: String) {
        let parameters: [String: Any] = [
            AFEventParamContentType: "paywall_dismissed",
            AFEventParam1: source
        ]
        
        logEvent(name: "paywall_dismissed", parameters: parameters)
    }
    
    // MARK: - Feature Usage Events
    
    func logFeatureUsed(featureName: String, parameters: [String: Any]? = nil) {
        var eventParams: [String: Any] = [
            AFEventParamContentType: "feature",
            AFEventParam1: featureName
        ]
        
        if let additionalParams = parameters {
            eventParams.merge(additionalParams) { _, new in new }
        }
        
        logEvent(name: "feature_used", parameters: eventParams)
    }
    
    func logShareAction(contentType: String, method: String) {
        let parameters: [String: Any] = [
            AFEventParamContentType: contentType,
            AFEventParam1: method
        ]
        
        logEvent(name: AFEventShare, parameters: parameters)
    }
    
    // MARK: - Error Events
    
    func logError(errorType: String, errorMessage: String) {
        let parameters: [String: Any] = [
            AFEventParamContentType: "error",
            AFEventParam1: errorType,
            AFEventParam2: errorMessage
        ]
        
        logEvent(name: "app_error", parameters: parameters)
    }
    
    // MARK: - Ad Revenue Events
    
    func logAdRevenue(
        monetizationNetwork: String,
        mediationNetwork: MediationNetworkType = .customMediation,
        revenue: Double,
        currency: String = "USD",
        adType: String? = nil,
        adUnit: String? = nil,
        placement: String? = nil,
        country: String? = nil
    ) {
        // Create ad revenue data object
        let adRevenueData = AFAdRevenueData(
            monetizationNetwork: monetizationNetwork,
            mediationNetwork: mediationNetwork,
            currencyIso4217Code: currency,
            eventRevenue: revenue
        )
        
        // Build additional parameters
        var additionalParameters: [String: Any] = [:]
        
        if let country = country {
            additionalParameters[kAppsFlyerAdRevenueCountry] = country
        }
        
        if let adType = adType {
            additionalParameters[kAppsFlyerAdRevenueAdType] = adType
        }
        
        if let adUnit = adUnit {
            additionalParameters[kAppsFlyerAdRevenueAdUnit] = adUnit
        }
        
        if let placement = placement {
            additionalParameters[kAppsFlyerAdRevenuePlacement] = placement
        }
        
        // Log the ad revenue
        AppsFlyerLib.shared().logAdRevenue(adRevenueData, additionalParameters: additionalParameters)
        
        print("AppsFlyer: Logged ad revenue - Network: \(monetizationNetwork), Revenue: \(revenue) \(currency)")
    }
    
    // MARK: - Facebook Ad Revenue
    
    func logFacebookAdRevenue(
        revenue: Double,
        currency: String = "USD",
        adType: String,
        adUnit: String? = nil,
        placement: String? = nil,
        country: String? = nil
    ) {
        logAdRevenue(
            monetizationNetwork: "facebook",
            mediationNetwork: .facebookAudienceNetwork,
            revenue: revenue,
            currency: currency,
            adType: adType,
            adUnit: adUnit,
            placement: placement,
            country: country
        )
    }
    
    // MARK: - TikTok Ad Revenue
    
    func logTikTokAdRevenue(
        revenue: Double,
        currency: String = "USD",
        adType: String,
        adUnit: String? = nil,
        placement: String? = nil,
        country: String? = nil
    ) {
        logAdRevenue(
            monetizationNetwork: "tiktok",
            mediationNetwork: .customMediation,
            revenue: revenue,
            currency: currency,
            adType: adType,
            adUnit: adUnit,
            placement: placement,
            country: country
        )
    }
    
    // MARK: - Private Helper
    
    private func logEvent(name: String, parameters: [String: Any]) {
        AppsFlyerLib.shared().logEvent(name, withValues: parameters) { (response, error) in
            if let error = error {
                print("AppsFlyer: Error logging event '\(name)': \(error.localizedDescription)")
            } else {
                print("AppsFlyer: Successfully logged event '\(name)'")
                if let response = response {
                    print("AppsFlyer: Response: \(response)")
                }
            }
        }
    }
}