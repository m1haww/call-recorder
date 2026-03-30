import SwiftUI

private enum OnboardingRegionGate {
    static var isKorea: Bool {
        return Locale.current.region?.identifier == "KR"
    }

    static var isJapan: Bool {
        return Locale.current.region?.identifier == "JP"
    }
}

struct OnboardingEntryView: View {
    @StateObject private var onboardingConfigManager = OnboardingRemoteConfigManager.shared

    var body: some View {
        if OnboardingRegionGate.isKorea {
            OnboardingKoreaVariant()
        } else if OnboardingRegionGate.isJapan {
            OnboardingJapanVariant()
        } else {
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
}
