import SwiftUI
import SuperwallKit
import StoreKit

struct OnboardingView: View {
    @ObservedObject var viewModel = AppViewModel.shared
    
    @State private var phoneNumber = ""
    @State private var selectedCountry = Country.defaultCountry
    @State private var showCountryPicker = false
    @State private var currentStep = 0
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @FocusState private var isTextFieldFocused: Bool
    
    let steps = [
        OnboardingStep(
            title: "Welcome to Call Recorder",
            subtitle: "Record and transcribe your important calls",
            icon: "phone.circle.fill"
        ),
        OnboardingStep(
            title: "Enter Your Phone Number",
            subtitle: "Select your country and enter your phone number",
            icon: "person.circle.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            if currentStep == 0 {
                GeometryReader { geometry in
                    ZStack {
                        Image("onboarding1")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300)
                            .ignoresSafeArea(edges: .all)
                        
                        VStack {
                            HStack(spacing: 8) {
                                ForEach(0..<steps.count, id: \.self) { index in
                                    Circle()
                                        .fill(index <= currentStep ? Color.primaryGreen : Color.white.opacity(0.3))
                                        .frame(width: 10, height: 10)
                                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                                }
                            }
                            .padding(.top, 60)
                            .padding(.bottom, 20)
                            
                            Spacer()
                            
                            VStack(spacing: 0) {
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.clear,
                                        Color.black.opacity(0.1),
                                        Color.black.opacity(0.2),
                                        Color.black.opacity(0.3),
                                        Color.black.opacity(0.4)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .frame(height: 150)
                                
                                Color.black.opacity(0.4)
                                    .frame(maxHeight: .infinity)
                            }
                            .ignoresSafeArea(edges: .bottom)
                            .overlay(
                                VStack(spacing: 24) {
                                    VStack(spacing: 16) {
                                        Text("Welcome to Call Recorder")
                                            .font(.largeTitle)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                                        
                                        Text("Record and transcribe your important\ncalls with ease")
                                            .font(.body)
                                            .foregroundColor(.white.opacity(0.95))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal)
                                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                                    }
                                    
                                    Button(action: nextStep) {
                                        Text("Next")
                                            .font(.system(size: 20, weight: .semibold))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 18)
                                            .background(Color.primaryGreen)
                                            .foregroundColor(.black)
                                            .cornerRadius(28)
                                    }
                                    .padding(.horizontal, 24)
                                }
                                    .padding(.bottom, 50)
                                , alignment: .bottom
                            )
                        }
                        .ignoresSafeArea(edges: .bottom)
                    }
                }
                .transition(.move(edge: .leading))
            } else {
                Color.darkBackground
                    .ignoresSafeArea()
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                
                ScrollView {
                    VStack(spacing: 0) {
                        HStack(spacing: 8) {
                            ForEach(0..<steps.count, id: \.self) { index in
                                Circle()
                                    .fill(index <= currentStep ? Color.primaryGreen : Color.surfaceBackground)
                                    .frame(width: 10, height: 10)
                                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                            }
                        }
                        .padding(.top, 50)
                        .padding(.bottom, 20)
                        
                        TabView(selection: $currentStep) {
                            ForEach(1..<steps.count, id: \.self) { index in
                                VStack(spacing: 24) {
                                    Image(systemName: steps[index].icon)
                                        .font(.system(size: 70))
                                        .foregroundColor(.primaryGreen)
                                    
                                    VStack(spacing: 12) {
                                        Text(steps[index].title)
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primaryText)
                                            .multilineTextAlignment(.center)
                                        
                                        Text(steps[index].subtitle)
                                            .font(.subheadline)
                                            .foregroundColor(.secondaryText)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 20)
                                    }
                                    
                                    getStepContent(for: index)
                                        .padding(.bottom, 20)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if index == 1 {
                                        withAnimation {
                                            isTextFieldFocused = false
                                        }
                                    }
                                }
                                .tag(index)
                            }
                        }
                        .frame(height: currentStep == 1 ? (isTextFieldFocused ? 350 : 500) : 500)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .onAppear(perform: {
                            UIScrollView.appearance().isScrollEnabled = false
                        })
                        
                        VStack(spacing: 16) {
                            Button(action: nextStep) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                            .scaleEffect(0.8)
                                    } else {
                                        Text(currentStep == 1 ? "Continue" : "Next")
                                            .font(.headline)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(canProceed ? Color.primaryGreen : Color.surfaceBackground)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                            }
                            .disabled(!canProceed || isLoading)
                            .animation(.easeInOut(duration: 0.2), value: canProceed)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
                .scrollDisabled(currentStep != 1 || !isTextFieldFocused)
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
        .alert("Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerView(selectedCountry: $selectedCountry)
        }
        .preferredColorScheme(.dark)
    }
    
    @ViewBuilder
    private func getStepContent(for step: Int) -> some View {
        switch step {
        case 1:
            VStack(spacing: 20) {
                Button(action: {
                    withAnimation {
                        showCountryPicker = true
                    }
                }) {
                    HStack {
                        Text("\(selectedCountry.flag) \(selectedCountry.name)")
                            .font(.title3)
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
                        .font(.title3)
                        .foregroundColor(.secondaryText)
                        .padding(.leading, 16)
                        .padding(.vertical, 16)
                    
                    TextField("Phone number", text: $phoneNumber)
                        .font(.title3)
                        .foregroundColor(.primaryText)
                        .padding(.trailing, 16)
                        .padding(.vertical, 16)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .padding(.leading, 7)
                        .focused($isTextFieldFocused)
                }
                .background(Color.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(showError ? Color.red : Color.surfaceBackground, lineWidth: 1)
                )
                
                Text("Enter your phone number without the country code")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 30)
            
        default:
            EmptyView()
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0: return true
        case 1: return isValidPhoneNumber(phoneNumber)
        default: return true
        }
    }
    
    private func nextStep() {
        isTextFieldFocused = false
        switch currentStep {
        case 0:
            withAnimation {
                currentStep += 1
            }
        case 1:
            if isValidPhoneNumber(phoneNumber) {
                registerUser()
            } else {
                showError = true
                errorMessage = "Please enter a valid phone number for \(selectedCountry.name)"
            }
        default:
            break
        }
    }
    
    private func registerUser() {
        let fullPhoneNumber = selectedCountry.dialCode + phoneNumber
        isLoading = true
        
        UserService.shared.registerUser(phoneNumber: fullPhoneNumber) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let userId):
                    print(userId)
                    
                    self.viewModel.saveUserPhoneNumber(fullPhoneNumber)
                    self.viewModel.saveUserCountry(code: self.selectedCountry.code, name: self.selectedCountry.name)
                    
                    self.completeOnboarding()
                    
                    Superwall.shared.register(placement: "campaign_trigger")
                    
                case .failure(let error):
                    self.showError = true
                    self.errorMessage = "Registration failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func completeOnboarding() {
        isTextFieldFocused = false
        viewModel.completeOnboarding()
        
        // Request app review after a slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
    
    private func isValidPhoneNumber(_ number: String) -> Bool {
        let cleanedNumber = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        return cleanedNumber.count >= 7 && cleanedNumber.count <= 15 && !cleanedNumber.isEmpty
    }
}

struct OnboardingStep {
    let title: String
    let subtitle: String
    let icon: String
}

