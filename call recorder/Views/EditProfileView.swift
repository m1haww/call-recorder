import SwiftUI

struct EditProfileView: View {
    let userName: String
    let phoneNumber: String
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = AppViewModel.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    
    @State private var editedName: String = ""
    @State private var editedPhoneNumber: String = ""
    @State private var selectedCountry = Country.defaultCountry
    @State private var showCountryPicker = false
    @State private var showSaveAlert = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Circle()
                        .fill(Color.primaryGreen.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(editedName.prefix(1).uppercased())
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryGreen)
                        )
                    
                    Text(localizationManager.localizedString("edit_profile_subtitle"))
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                .padding(.top, 20)
                
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localizationManager.localizedString("full_name"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primaryText)
                        
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(.secondaryText)
                            
                            TextField(localizationManager.localizedString("enter_full_name"), text: $editedName)
                                .foregroundColor(.primaryText)
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.surfaceBackground, lineWidth: 1)
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localizationManager.localizedString("phone_number"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primaryText)
                        
                        VStack(spacing: 12) {
                            Button(action: {
                                showCountryPicker = true
                            }) {
                                HStack {
                                    Text("\(selectedCountry.flag) \(selectedCountry.name)")
                                        .foregroundColor(.primaryText)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.secondaryText)
                                        .font(.caption)
                                }
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.surfaceBackground, lineWidth: 1)
                                )
                            }
                            
                            HStack(spacing: 0) {
                                Text(selectedCountry.dialCode)
                                    .font(.body)
                                    .foregroundColor(.secondaryText)
                                    .padding(.leading, 16)
                                    .padding(.vertical, 16)
                                
                                TextField(localizationManager.localizedString("phone_number_placeholder"), text: $editedPhoneNumber)
                                    .font(.body)
                                    .foregroundColor(.primaryText)
                                    .padding(.trailing, 16)
                                    .padding(.vertical, 16)
                                    .keyboardType(.phonePad)
                                    .textContentType(.telephoneNumber)
                                    .padding(.leading, 7)
                            }
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(showError ? Color.red : Color.surfaceBackground, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    saveChanges()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text(localizationManager.localizedString("save_changes"))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.black)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.primaryGreen, .accentGreen]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                }
                .padding(.horizontal)
                .disabled(editedName.isEmpty || isValidPhoneNumber(editedPhoneNumber) == false || isLoading)
                .opacity((editedName.isEmpty || isValidPhoneNumber(editedPhoneNumber) == false || isLoading) ? 0.6 : 1.0)
            }
            .background(Color.darkBackground)
            .navigationTitle(localizationManager.localizedString("edit_profile"))
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localizationManager.localizedString("cancel")) {
                        dismiss()
                    }
                    .foregroundColor(.primaryGreen)
                }
            }
            .onAppear {
                editedName = userName
                setupPhoneNumber()
            }
            .sheet(isPresented: $showCountryPicker) {
                CountryPickerView(selectedCountry: $selectedCountry)
            }
            .alert(localizationManager.localizedString("error"), isPresented: $showError) {
                Button(localizationManager.localizedString("ok")) {}
            } message: {
                Text(errorMessage)
            }
        }
        .alert(localizationManager.localizedString("profile_updated"), isPresented: $showSaveAlert) {
            Button(localizationManager.localizedString("ok")) {
                dismiss()
            }
        } message: {
            Text(localizationManager.localizedString("profile_updated_message"))
        }
    }
    
    private func setupPhoneNumber() {
        if !viewModel.userPhoneNumber.isEmpty {
            if let country = Country.allCountries.first(where: { viewModel.userPhoneNumber.hasPrefix($0.dialCode) }) {
                selectedCountry = country
                editedPhoneNumber = String(viewModel.userPhoneNumber.dropFirst(country.dialCode.count))
            } else {
                editedPhoneNumber = viewModel.userPhoneNumber
            }
        }
    }
    
    private func isValidPhoneNumber(_ number: String) -> Bool {
        let cleanedNumber = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return cleanedNumber.count >= 7 && cleanedNumber.count <= 15 && !cleanedNumber.isEmpty
    }
    
    private func saveChanges() {
        let fullPhoneNumber = selectedCountry.dialCode + editedPhoneNumber
        
        let phoneChanged = fullPhoneNumber != viewModel.userPhoneNumber
        
        isLoading = true
        
        UserDefaults.standard.set(editedName, forKey: "userName")
        viewModel.userName = editedName
        
        if phoneChanged {
            Task {
                await updatePhoneNumber(fullPhoneNumber)
            }
        } else {
            isLoading = false
            showSaveAlert = true
        }
    }
    
    @MainActor
    private func updatePhoneNumber(_ fullPhoneNumber: String) async {
        do {
            let success = try await UserService.shared.updateUserPhoneNumber(userId: viewModel.userId,newPhoneNumber: fullPhoneNumber, countryCode: selectedCountry.code)
            
            if success {
                viewModel.userPhoneNumber = fullPhoneNumber
                viewModel.userCountryCode = selectedCountry.code
                
                isLoading = false
                showSaveAlert = true
            } else {
                isLoading = false
                showError = true
                errorMessage = localizationManager.localizedString("failed_update_phone")
            }
        } catch {
            isLoading = false
            showError = true
            errorMessage = String(format: localizationManager.localizedString("error_updating_phone"), error.localizedDescription)
        }
    }
}
