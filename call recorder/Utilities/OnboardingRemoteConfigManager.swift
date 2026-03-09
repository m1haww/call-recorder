import Foundation
import FirebaseRemoteConfig
import SwiftUI
import Combine

final class OnboardingRemoteConfigManager: ObservableObject {
    static let shared = OnboardingRemoteConfigManager()
    private let parameterKey = "onboarding_variant"
    
    @Published var onboardingVariant = OnboardingABVariant.a
    
    func fetchAndActivate() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        remoteConfig.fetchAndActivate { status, _ in
            switch status {
            case .successFetchedFromRemote, .successUsingPreFetchedData:
                print("Successfully fetched remote config")
                self.loadOnboardingVariant()
                break
            default:
                print("Failed to fetch or activate remote config")
                break
            }
        }
    }
    
    func loadOnboardingVariant() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let value = remoteConfig.configValue(forKey: parameterKey).stringValue.lowercased()
        guard let variant = OnboardingABVariant(rawValue: value) else { return }
        self.onboardingVariant = variant
    }
}
