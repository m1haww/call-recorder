import Foundation
import FirebaseRemoteConfig

/// Manager for onboarding A/B variant from Firebase Remote Config.
/// Fetch is triggered at app launch; variant is read from activated config.
enum OnboardingRemoteConfigManager {
    private static let parameterKey = "onboarding_variant"
    
    /// Call once at app launch (e.g. in AppDelegate after FirebaseApp.configure()).
    static func fetchAndActivate() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0 // Development; use 3600 or 43200 in production
        remoteConfig.configSettings = settings
        
        // Default: "a" so app works before you set values in Firebase
        remoteConfig.setDefaults([parameterKey: "a" as NSObject])
        
        remoteConfig.fetchAndActivate { status, _ in
            switch status {
            case .successFetchedFromRemote, .successUsingPreFetchedData:
                break
            default:
                break
            }
        }
    }
    
    /// Returns the onboarding variant from Remote Config, or nil if not set / invalid.
    static func onboardingVariant() -> OnboardingABVariant? {
        let remoteConfig = RemoteConfig.remoteConfig()
        let value = remoteConfig.configValue(forKey: parameterKey).stringValue?.lowercased()
        guard let value, let variant = OnboardingABVariant(rawValue: value) else { return nil }
        return variant
    }
}
