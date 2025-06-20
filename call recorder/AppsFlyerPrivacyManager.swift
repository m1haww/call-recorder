import Foundation
import AppsFlyerLib

final class AppsFlyerPrivacyManager {
    
    static let shared = AppsFlyerPrivacyManager()
    
    // MARK: - Privacy Settings Keys
    
    private enum PrivacyKeys {
        static let hasUserConsent = "appsflyer_user_consent"
        static let isAnonymized = "appsflyer_anonymized"
        static let sharingRestrictions = "appsflyer_sharing_restrictions"
        static let disableIDFA = "appsflyer_disable_idfa"
        static let disableIDFV = "appsflyer_disable_idfv"
        static let installOnlyMode = "appsflyer_install_only"
        static let isSubjectToGDPR = "appsflyer_subject_to_gdpr"
        static let hasConsentForDataUsage = "appsflyer_consent_data_usage"
        static let hasConsentForAdsPersonalization = "appsflyer_consent_ads_personalization"
        static let hasConsentForAdStorage = "appsflyer_consent_ad_storage"
        static let tcfDataCollectionEnabled = "appsflyer_tcf_data_collection"
    }
    
    // MARK: - Properties
    
    var hasUserConsent: Bool {
        get { UserDefaults.standard.bool(forKey: PrivacyKeys.hasUserConsent) }
        set { 
            UserDefaults.standard.set(newValue, forKey: PrivacyKeys.hasUserConsent)
            handleConsentChange(newValue)
        }
    }
    
    var isAnonymized: Bool {
        get { UserDefaults.standard.bool(forKey: PrivacyKeys.isAnonymized) }
        set { 
            UserDefaults.standard.set(newValue, forKey: PrivacyKeys.isAnonymized)
            AppsFlyerLib.shared().anonymizeUser = newValue
        }
    }
    
    var installOnlyMode: Bool {
        get { UserDefaults.standard.bool(forKey: PrivacyKeys.installOnlyMode) }
        set { UserDefaults.standard.set(newValue, forKey: PrivacyKeys.installOnlyMode) }
    }
    
    private var blockedPartners: Set<String> {
        get {
            let array = UserDefaults.standard.stringArray(forKey: PrivacyKeys.sharingRestrictions) ?? []
            return Set(array)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: PrivacyKeys.sharingRestrictions)
        }
    }
    
    // MARK: - DMA Compliance Properties
    
    var isSubjectToGDPR: Bool {
        get { UserDefaults.standard.bool(forKey: PrivacyKeys.isSubjectToGDPR) }
        set { UserDefaults.standard.set(newValue, forKey: PrivacyKeys.isSubjectToGDPR) }
    }
    
    var hasConsentForDataUsage: Bool? {
        get { 
            guard UserDefaults.standard.object(forKey: PrivacyKeys.hasConsentForDataUsage) != nil else { return nil }
            return UserDefaults.standard.bool(forKey: PrivacyKeys.hasConsentForDataUsage)
        }
        set { 
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: PrivacyKeys.hasConsentForDataUsage)
            } else {
                UserDefaults.standard.removeObject(forKey: PrivacyKeys.hasConsentForDataUsage)
            }
        }
    }
    
    var hasConsentForAdsPersonalization: Bool? {
        get { 
            guard UserDefaults.standard.object(forKey: PrivacyKeys.hasConsentForAdsPersonalization) != nil else { return nil }
            return UserDefaults.standard.bool(forKey: PrivacyKeys.hasConsentForAdsPersonalization)
        }
        set { 
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: PrivacyKeys.hasConsentForAdsPersonalization)
            } else {
                UserDefaults.standard.removeObject(forKey: PrivacyKeys.hasConsentForAdsPersonalization)
            }
        }
    }
    
    var hasConsentForAdStorage: Bool? {
        get { 
            guard UserDefaults.standard.object(forKey: PrivacyKeys.hasConsentForAdStorage) != nil else { return nil }
            return UserDefaults.standard.bool(forKey: PrivacyKeys.hasConsentForAdStorage)
        }
        set { 
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: PrivacyKeys.hasConsentForAdStorage)
            } else {
                UserDefaults.standard.removeObject(forKey: PrivacyKeys.hasConsentForAdStorage)
            }
        }
    }
    
    var tcfDataCollectionEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: PrivacyKeys.tcfDataCollectionEnabled) }
        set { 
            UserDefaults.standard.set(newValue, forKey: PrivacyKeys.tcfDataCollectionEnabled)
            AppsFlyerLib.shared().enableTCFDataCollection = newValue
        }
    }
    
    private init() {}
    
    // MARK: - Consent Management
    
    func requestUserConsent(completion: @escaping (Bool) -> Void) {
        // This is where you would show your consent dialog
        // For now, we'll simulate it
        DispatchQueue.main.async {
            // In a real app, show your consent UI here
            // For example: present a consent dialog, privacy policy, etc.
            completion(true) // User gave consent
        }
    }
    
    func updateConsent(_ hasConsent: Bool) {
        hasUserConsent = hasConsent
    }
    
    // MARK: - DMA Compliance Methods
    
    func setGDPRConsent(
        isSubjectToGDPR: Bool,
        hasConsentForDataUsage: Bool? = nil,
        hasConsentForAdsPersonalization: Bool? = nil,
        hasConsentForAdStorage: Bool? = nil
    ) {
        self.isSubjectToGDPR = isSubjectToGDPR
        self.hasConsentForDataUsage = hasConsentForDataUsage
        self.hasConsentForAdsPersonalization = hasConsentForAdsPersonalization
        self.hasConsentForAdStorage = hasConsentForAdStorage
        
        // Create and set AppsFlyerConsent object
        let consent = AppsFlyerConsent(
            isUserSubjectToGDPR: isSubjectToGDPR,
            hasConsentForDataUsage: hasConsentForDataUsage,
            hasConsentForAdsPersonalization: hasConsentForAdsPersonalization,
            hasConsentForAdStorage: hasConsentForAdStorage
        )
        
        AppsFlyerLib.shared().setConsentData(consent)
    }
    
    func enableTCFDataCollection(_ enable: Bool) {
        tcfDataCollectionEnabled = enable
    }
    
    func detectGDPRApplicability() -> Bool {
        // Basic EU/EEA detection based on locale
        // In production, use a more robust geo-detection service
        let locale = Locale.current
        let euCountryCodes = [
            "AT", "BE", "BG", "HR", "CY", "CZ", "DK", "EE", "FI", "FR",
            "DE", "GR", "HU", "IE", "IT", "LV", "LT", "LU", "MT", "NL",
            "PL", "PT", "RO", "SK", "SI", "ES", "SE", "IS", "LI", "NO"
        ]
        
        if let countryCode = locale.regionCode {
            return euCountryCodes.contains(countryCode)
        }
        
        return false
    }
    
    func requestGDPRConsent(completion: @escaping (Bool) -> Void) {
        // Check if GDPR applies to this user
        let subjectToGDPR = detectGDPRApplicability()
        
        if !subjectToGDPR {
            // User not subject to GDPR - set consent accordingly
            setGDPRConsent(
                isSubjectToGDPR: false,
                hasConsentForDataUsage: nil,
                hasConsentForAdsPersonalization: nil,
                hasConsentForAdStorage: nil
            )
            completion(true)
            return
        }
        
        // For GDPR-subject users, you would show a proper consent dialog here
        // This is a placeholder that should be replaced with your actual consent UI
        DispatchQueue.main.async {
            // In a real implementation, present a GDPR consent dialog
            // For now, we'll simulate user consent
            
            // Example consent values - replace with actual user choices
            let dataUsageConsent = true
            let adsPersonalizationConsent = false
            let adStorageConsent = true
            
            self.setGDPRConsent(
                isSubjectToGDPR: true,
                hasConsentForDataUsage: dataUsageConsent,
                hasConsentForAdsPersonalization: adsPersonalizationConsent,
                hasConsentForAdStorage: adStorageConsent
            )
            
            completion(true)
        }
    }
    
    private func handleConsentChange(_ hasConsent: Bool) {
        if hasConsent {
            // User gave consent - start tracking if not already started
            if !AppsFlyerLib.shared().isStopped {
                AppsFlyerLib.shared().start()
            }
        } else {
            // User revoked consent - stop tracking
            AppsFlyerLib.shared().isStopped = true
        }
    }
    
    // MARK: - Initialize SDK with Privacy Settings
    
    func initializeWithPrivacy() {
        // Enable TCF data collection if configured
        if tcfDataCollectionEnabled {
            AppsFlyerLib.shared().enableTCFDataCollection = true
        }
        
        // Set DMA consent if configured
        setDMAConsentIfAvailable()
        
        // Check if we have user consent before starting
        guard hasUserConsent else {
            print("AppsFlyer: No user consent - SDK will not start")
            AppsFlyerLib.shared().isStopped = true
            return
        }
        
        // Apply privacy settings
        applyPrivacySettings()
        
        // Handle install-only mode
        if installOnlyMode {
            startInstallOnlyMode()
        } else {
            // Normal start
            AppsFlyerLib.shared().start()
        }
    }
    
    private func setDMAConsentIfAvailable() {
        // Only set consent data if we have explicit GDPR determination
        guard UserDefaults.standard.object(forKey: PrivacyKeys.isSubjectToGDPR) != nil else {
            return
        }
        
        let consent = AppsFlyerConsent(
            isUserSubjectToGDPR: isSubjectToGDPR,
            hasConsentForDataUsage: hasConsentForDataUsage,
            hasConsentForAdsPersonalization: hasConsentForAdsPersonalization,
            hasConsentForAdStorage: hasConsentForAdStorage
        )
        
        AppsFlyerLib.shared().setConsentData(consent)
    }
    
    private func applyPrivacySettings() {
        // Apply anonymization if enabled
        if isAnonymized {
            AppsFlyerLib.shared().anonymizeUser = true
        }
        
        // Apply identifier restrictions
        if UserDefaults.standard.bool(forKey: PrivacyKeys.disableIDFA) {
            AppsFlyerLib.shared().disableAdvertisingIdentifier = true
        }
        
        if UserDefaults.standard.bool(forKey: PrivacyKeys.disableIDFV) {
            AppsFlyerLib.shared().disableIDFVCollection = true
        }
        
        // Apply partner restrictions
        if !blockedPartners.isEmpty {
            AppsFlyerLib.shared().setSharingFilterForPartners(Array(blockedPartners))
        }
    }
    
    // MARK: - Install Only Mode
    
    private func startInstallOnlyMode() {
        // Start SDK with completion handler to stop after install
        AppsFlyerLib.shared().start { (dictionary, error) in
            if error != nil {
                print("AppsFlyer: Error during install-only start: \(error?.localizedDescription ?? "Unknown error")")
            } else {
                print("AppsFlyer: Install event sent successfully, stopping further tracking")
                AppsFlyerLib.shared().isStopped = true
            }
        }
    }
    
    // MARK: - Third Party Data Sharing
    
    func blockPartners(_ partners: [String]) {
        blockedPartners = blockedPartners.union(partners)
        AppsFlyerLib.shared().setSharingFilterForPartners(Array(blockedPartners))
    }
    
    func unblockPartners(_ partners: [String]) {
        partners.forEach { blockedPartners.remove($0) }
        AppsFlyerLib.shared().setSharingFilterForPartners(Array(blockedPartners))
    }
    
    func blockAllPartners() {
        let allPartners = ["all"]
        blockedPartners = Set(allPartners)
        AppsFlyerLib.shared().setSharingFilterForPartners(allPartners)
    }
    
    func unblockAllPartners() {
        blockedPartners.removeAll()
        AppsFlyerLib.shared().setSharingFilterForPartners([])
    }
    
    // MARK: - Identifier Management
    
    func disableAdvertisingIdentifier(_ disable: Bool) {
        UserDefaults.standard.set(disable, forKey: PrivacyKeys.disableIDFA)
        AppsFlyerLib.shared().disableAdvertisingIdentifier = disable
    }
    
    func disableIDFVCollection(_ disable: Bool) {
        UserDefaults.standard.set(disable, forKey: PrivacyKeys.disableIDFV)
        AppsFlyerLib.shared().disableIDFVCollection = disable
    }
    
    // MARK: - Complete Privacy Reset
    
    func resetAllPrivacySettings() {
        hasUserConsent = false
        isAnonymized = false
        installOnlyMode = false
        blockedPartners.removeAll()
        disableAdvertisingIdentifier(false)
        disableIDFVCollection(false)
        
        // Reset DMA compliance settings
        isSubjectToGDPR = false
        hasConsentForDataUsage = nil
        hasConsentForAdsPersonalization = nil
        hasConsentForAdStorage = nil
        tcfDataCollectionEnabled = false
        
        // Stop SDK
        AppsFlyerLib.shared().isStopped = true
    }
    
    // MARK: - Privacy Status
    
    func getCurrentPrivacyStatus() -> [String: Any] {
        return [
            "hasConsent": hasUserConsent,
            "isAnonymized": isAnonymized,
            "installOnlyMode": installOnlyMode,
            "blockedPartners": Array(blockedPartners),
            "disableIDFA": UserDefaults.standard.bool(forKey: PrivacyKeys.disableIDFA),
            "disableIDFV": UserDefaults.standard.bool(forKey: PrivacyKeys.disableIDFV),
            "isSDKStopped": AppsFlyerLib.shared().isStopped,
            "isSubjectToGDPR": isSubjectToGDPR,
            "hasConsentForDataUsage": hasConsentForDataUsage as Any,
            "hasConsentForAdsPersonalization": hasConsentForAdsPersonalization as Any,
            "hasConsentForAdStorage": hasConsentForAdStorage as Any,
            "tcfDataCollectionEnabled": tcfDataCollectionEnabled
        ]
    }
}

// MARK: - Common Partner Constants

extension AppsFlyerPrivacyManager {
    enum CommonPartners {
        static let facebook = "facebook_int"
        static let google = "googleadwords_int"
        static let twitter = "twitter_int"
        static let snapchat = "snapchat_int"
        static let tiktok = "bytedanceglobal_int"
        static let amazon = "amazon_ads_int"
        static let apple = "apple_search_ads"
    }
}