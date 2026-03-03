import SwiftUI

/// Entry point for onboarding A/B testing. Picks variant A, B, or C and shows the corresponding onboarding flow.
struct OnboardingEntryView: View {
    /// Set to .a, .b or .c to always test that variant. Set to nil for real A/B distribution (Firebase Remote Config / random).
    private static let forcedVariantForTesting: OnboardingABVariant? = nil

    private let variant: OnboardingABVariant = OnboardingEntryView.resolveVariant()

    var body: some View {
        switch variant {
        case .a:
            OnboardingVariantA()
        case .b:
            OnboardingVariantB()
        case .c:
            OnboardingVariantC()
        }
    }

    /// Resolves which variant to show: 1) forced for testing, 2) Firebase Remote Config, 3) persisted UserDefaults, 4) random (then persist).
    private static func resolveVariant() -> OnboardingABVariant {
        if let forced = forcedVariantForTesting { return forced }
        if let variant = OnboardingRemoteConfigManager.onboardingVariant() {
            UserDefaults.standard.set(variant.rawValue, forKey: "onboarding_ab_variant")
            return variant
        }
        let key = "onboarding_ab_variant"
        if let raw = UserDefaults.standard.string(forKey: key),
           let variant = OnboardingABVariant(rawValue: raw) {
            return variant
        }
        let chosen = OnboardingABVariant.allCases.randomElement() ?? .a
        UserDefaults.standard.set(chosen.rawValue, forKey: key)
        return chosen
    }
}
