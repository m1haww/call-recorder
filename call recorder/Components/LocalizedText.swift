import SwiftUI

struct LocalizedText: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    let key: String
    
    var body: some View {
        Text(localizationManager.localizedString(key))
    }
}

// Helper function to create localized text
func Localized(_ key: String) -> LocalizedText {
    LocalizedText(key: key)
}

// For use in places that need String (like navigation titles)
struct LocalizedStringKey {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    let key: String
    
    var value: String {
        localizationManager.localizedString(key)
    }
}