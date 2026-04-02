import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(String(localized: "Privacy Policy"))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryText)
                        
                        Text("\(String(localized: "Last updated:")) \(Date().formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        PolicySection(
                            title: String(localized: "Information We Collect"),
                            content: String(localized: "We collect information you provide directly to us, such as when you create an account, record calls, or contact us for support. This may include your name, email address, phone number, and call recordings.")
                        )
                        
                        PolicySection(
                            title: String(localized: "How We Use Your Information"),
                            content: String(localized: "We use the information we collect to provide, maintain, and improve our services, process transactions, send you technical notices and support messages, and respond to your comments and questions.")
                        )
                        
                        PolicySection(
                            title: String(localized: "Information Sharing"),
                            content: String(localized: "We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy or as required by law.")
                        )
                        
                        PolicySection(
                            title: String(localized: "Data Security"),
                            content: String(localized: "We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. All call recordings are encrypted end-to-end.")
                        )
                        
                        PolicySection(
                            title: String(localized: "Your Rights"),
                            content: String(localized: "You have the right to access, update, or delete your personal information. You can also request that we stop processing your data or transfer your data to another service.")
                        )
                        
                        PolicySection(
                            title: String(localized: "Contact Us"),
                            content: String(localized: "If you have any questions about this Privacy Policy, please contact us at privacy@callrecorder.com")
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
                    Button(String(localized: "Done")) {
                        dismiss()
                    }
                    .foregroundColor(.primaryGreen)
                }
            }
        }
    }
}

struct PolicySection: View {
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
