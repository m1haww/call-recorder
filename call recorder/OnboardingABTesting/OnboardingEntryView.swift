import SwiftUI

/// Entry point for onboarding A/B testing. Picks variant A, B, or C and shows the corresponding onboarding flow.
struct OnboardingEntryView: View {
    /// Set to .a, .b or .c to always test that variant. Set to nil for real A/B distribution.
    private static let forcedVariantForTesting: OnboardingABVariant? = .c

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

    /// Resolves which variant to show (persisted per install for consistent experience).
    private static func resolveVariant() -> OnboardingABVariant {
        if let forced = forcedVariantForTesting { return forced }
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
