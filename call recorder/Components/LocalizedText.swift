import SwiftUI

struct LocalizedText: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    let key: String
    
    var body: some View {
        Text(localizationManager.localizedString(key))
    }
}

func Localized(_ key: String) -> LocalizedText {
    LocalizedText(key: key)
}

struct LocalizedStringKey {
    @StateObject private var localizationManager = LocalizationManager.shared
    let key: String
    
    var value: String {
        localizationManager.localizedString(key)
    }
}
