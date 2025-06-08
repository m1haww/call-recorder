import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Terms of Service")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryText)
                        
                        Text("Last updated: \(Date().formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        TermsSection(
                            title: "Acceptance of Terms",
                            content: "By accessing and using Call Recorder, you accept and agree to be bound by the terms and provision of this agreement."
                        )
                        
                        TermsSection(
                            title: "Legal Compliance",
                            content: "You are responsible for ensuring that your use of this app complies with all applicable laws and regulations regarding call recording in your jurisdiction. Some areas require consent from all parties before recording."
                        )
                        
                        TermsSection(
                            title: "Prohibited Uses",
                            content: "You may not use this app for any unlawful purpose or to solicit others to perform unlawful acts. You are prohibited from recording calls without proper consent where required by law."
                        )
                        
                        TermsSection(
                            title: "Service Availability",
                            content: "We strive to keep the app available at all times, but we cannot guarantee uninterrupted service. We reserve the right to modify or discontinue the service with reasonable notice."
                        )
                        
                        TermsSection(
                            title: "Limitation of Liability",
                            content: "In no event shall Call Recorder be liable for any indirect, incidental, special, consequential, or punitive damages arising out of your use of the service."
                        )
                        
                        TermsSection(
                            title: "Changes to Terms",
                            content: "We reserve the right to modify these terms at any time. Users will be notified of significant changes via email or app notification."
                        )
                    }
                }
                .padding()
            }
            .background(Color.darkBackground)
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryGreen)
                }
            }
        }
    }
}

struct TermsSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primaryText)
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.surfaceBackground, lineWidth: 1)
        )
    }
}

#Preview {
    TermsOfServiceView()
}