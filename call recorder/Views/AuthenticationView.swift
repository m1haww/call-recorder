import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var isSignUp = false
    @State private var showSkipConfirmation = false
    
    var body: some View {
        ZStack {
            Color.darkBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 20) {
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.primaryGreen)
                    
                    VStack(spacing: 8) {
                        Text("Call Recorder")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryText)
                        
                        Text("Record and manage your calls securely")
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                // Authentication Form
                if isSignUp {
                    SignUpView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                } else {
                    SignInView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .trailing)
                        ))
                }
                
                Spacer()
                
                // Toggle between Sign In / Sign Up
                HStack(spacing: 4) {
                    Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSignUp.toggle()
                        }
                    }) {
                        Text(isSignUp ? "Sign In" : "Sign Up")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryGreen)
                    }
                }
                .padding(.bottom, 20)
                
                // Skip Authentication
                Button(action: {
                    showSkipConfirmation = true
                }) {
                    Text("Continue as Guest")
                        .font(.subheadline)
                        .foregroundColor(.tertiaryText)
                        .underline()
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
        .preferredColorScheme(.dark)
        .alert("Continue as Guest", isPresented: $showSkipConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Continue") {
                authManager.skipAuthenticationFlow()
            }
        } message: {
            Text("You can create an account later to sync your data across devices.")
        }
    }
}

struct SignInView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var selectedCountry = Country.allCountries.first { $0.code == "US" } ?? Country.allCountries[0]
    @State private var showCountryPicker = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showAppleSignIn = false
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Welcome Back")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                
                Text("Sign in to your account")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
            }
            
            VStack(spacing: 16) {
                // Email Field (Optional)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email (Optional)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryText)
                    
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.secondaryText)
                        
                        TextField("Enter your email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
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
                
                // Phone Number Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Phone Number")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryText)
                    
                    HStack(spacing: 0) {
                        // Country Selection Button
                        Button(action: {
                            showCountryPicker = true
                        }) {
                            HStack(spacing: 8) {
                                Text(selectedCountry.flag)
                                    .font(.title2)
                                Text(selectedCountry.dialCode)
                                    .font(.subheadline)
                                    .foregroundColor(.primaryText)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondaryText)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.surfaceBackground)
                            .cornerRadius(12, corners: [.topLeft, .bottomLeft])
                        }
                        
                        // Phone Number Input
                        TextField("Phone number", text: $phoneNumber)
                            .keyboardType(.phonePad)
                            .foregroundColor(.primaryText)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.cardBackground)
                            .cornerRadius(12, corners: [.topRight, .bottomRight])
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.surfaceBackground, lineWidth: 1)
                    )
                }
            }
            
            // Apple Sign In
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.email, .fullName]
                },
                onCompletion: { result in
                    handleAppleSignIn(result)
                }
            )
            .signInWithAppleButtonStyle(.white)
            .frame(height: 50)
            .cornerRadius(25)
            
            // Sign In Button
            Button(action: signIn) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text("Sign In")
                        .font(.headline)
                        .fontWeight(.semibold)
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
            .disabled(phoneNumber.isEmpty || isLoading)
            .opacity(phoneNumber.isEmpty ? 0.6 : 1.0)
        }
        .alert("Sign In Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerView(selectedCountry: $selectedCountry)
        }
    }
    
    private func signIn() {
        isLoading = true
        
        let fullPhoneNumber = selectedCountry.dialCode + phoneNumber
        
        if !email.isEmpty {
            // Sign in with email and phone
            authManager.signIn(email: email, phoneNumber: fullPhoneNumber) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
        } else {
            // Sign in with phone only
            authManager.signInWithPhoneOnly(phoneNumber: fullPhoneNumber) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
        }
    }
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userID = appleIDCredential.user
                let email = appleIDCredential.email ?? ""
                let fullName = "\(appleIDCredential.fullName?.givenName ?? "") \(appleIDCredential.fullName?.familyName ?? "")".trimmingCharacters(in: .whitespaces)
                
                // Register/sign in with Apple ID
                let fullPhoneNumber = selectedCountry.dialCode + phoneNumber
                authManager.signUp(email: email, fullName: fullName.isEmpty ? "Apple User" : fullName, phoneNumber: fullPhoneNumber, appleID: userID) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
                }
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

struct SignUpView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var fullName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var selectedCountry = Country.allCountries.first { $0.code == "US" } ?? Country.allCountries[0]
    @State private var showCountryPicker = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Create Account")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                
                Text("Sign up to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
            }
            
            VStack(spacing: 16) {
                // Full Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Full Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryText)
                    
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.secondaryText)
                        
                        TextField("Enter your full name", text: $fullName)
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
                
                // Email Field (Optional)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email (Optional)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryText)
                    
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.secondaryText)
                        
                        TextField("Enter your email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
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
                
                // Phone Number Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Phone Number")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryText)
                    
                    HStack(spacing: 0) {
                        // Country Selection Button
                        Button(action: {
                            showCountryPicker = true
                        }) {
                            HStack(spacing: 8) {
                                Text(selectedCountry.flag)
                                    .font(.title2)
                                Text(selectedCountry.dialCode)
                                    .font(.subheadline)
                                    .foregroundColor(.primaryText)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondaryText)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.surfaceBackground)
                            .cornerRadius(12, corners: [.topLeft, .bottomLeft])
                        }
                        
                        // Phone Number Input
                        TextField("Phone number", text: $phoneNumber)
                            .keyboardType(.phonePad)
                            .foregroundColor(.primaryText)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.cardBackground)
                            .cornerRadius(12, corners: [.topRight, .bottomRight])
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.surfaceBackground, lineWidth: 1)
                    )
                }
            }
            
            // Sign Up Button
            Button(action: signUp) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text("Create Account")
                        .font(.headline)
                        .fontWeight(.semibold)
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
            .disabled(!isFormValid || isLoading)
            .opacity(isFormValid ? 1.0 : 0.6)
        }
        .alert("Sign Up Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerView(selectedCountry: $selectedCountry)
        }
    }
    
    private var isFormValid: Bool {
        !fullName.isEmpty && !phoneNumber.isEmpty
    }
    
    private func signUp() {
        isLoading = true
        
        let fullPhoneNumber = selectedCountry.dialCode + phoneNumber
        
        authManager.signUp(email: email, fullName: fullName, phoneNumber: fullPhoneNumber) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    break
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

#Preview {
    AuthenticationView()
}