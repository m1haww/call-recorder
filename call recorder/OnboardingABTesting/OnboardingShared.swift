import SwiftUI

// MARK: - Shared types for onboarding A/B testing

enum OnboardingABVariant: String, CaseIterable {
    case a
    case b
    case c
}

struct OnboardingStep: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
}

extension OnboardingStep {
    static let defaultSteps: [OnboardingStep] = [
        OnboardingStep(
            title: "Welcome to Call Recorder",
            subtitle: "Record and transcribe your important calls",
            icon: "phone.circle.fill"
        ),
        OnboardingStep(
            title: "Smart Call Recording",
            subtitle: "AI-powered transcription with 99% accuracy",
            icon: "waveform.circle.fill"
        ),
        OnboardingStep(
            title: "Instant Summary & Insights",
            subtitle: "Get key points and action items automatically",
            icon: "sparkles"
        ),
        OnboardingStep(
            title: "Enter Your Phone Number",
            subtitle: "Select your country and enter your phone number",
            icon: "person.circle.fill"
        )
    ]
}
