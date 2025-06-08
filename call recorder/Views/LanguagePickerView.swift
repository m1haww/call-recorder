import SwiftUI

struct LanguagePickerView: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(LocalizationManager.Language.allCases) { language in
                    Button(action: {
                        localizationManager.setLanguage(language)
                        dismiss()
                    }) {
                        HStack {
                            Text(language.displayName)
                                .font(.subheadline)
                                .foregroundColor(.primaryText)
                            
                            Spacer()
                            
                            if localizationManager.currentLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.primaryGreen)
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Color.cardBackground)
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.darkBackground)
            .navigationTitle("Language")
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

#Preview {
    LanguagePickerView()
        .environmentObject(LocalizationManager.shared)
}