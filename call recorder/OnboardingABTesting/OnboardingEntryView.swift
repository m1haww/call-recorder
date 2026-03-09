import SwiftUI

struct OnboardingEntryView: View {
    @StateObject private var onboardingConfigManager = OnboardingRemoteConfigManager.shared
    
    var body: some View {
        switch onboardingConfigManager.onboardingVariant {
        case .a:
            OnboardingVariantA()
        case .b:
            OnboardingVariantB()
        case .c:
            OnboardingVariantC()
        }
    }
}
