import SwiftUI
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
    @State private var imageScale: CGFloat = 1.0
    @State private var imageOffset: CGFloat = 0
    @State private var contentOpacity: Double = 1.0
    @State private var buttonScale: CGFloat = 1.0
    
    let steps = [
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
    
    var body: some View {
        ZStack {
            if currentStep <= 2 {
                GeometryReader { geometry in
                    ZStack {
                        Image(currentStep == 0 ? "onboarding1" : currentStep == 1 ? "onboarding2" : "onboarding3")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300)
                            .scaleEffect(imageScale)
                            .offset(x: imageOffset)
                            .ignoresSafeArea(edges: .all)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0), value: currentStep)
                        
                        VStack {
                            HStack(spacing: 8) {
                                ForEach(0..<steps.count, id: \.self) { index in
                                    Circle()
                                        .fill(index <= currentStep ? Color.primaryGreen : Color.white.opacity(0.3))
                                        .frame(width: 10, height: 10)
                                        .scaleEffect(index == currentStep ? 1.3 : 1.0)
                                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: currentStep)
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
                                        Text(steps[currentStep].title)
                                            .font(.largeTitle)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                                            .opacity(contentOpacity)
                                            .animation(.easeOut(duration: 0.3).delay(0.1), value: currentStep)
                                        
                                        Text(getOnboardingSubtitle(for: currentStep))
                                            .font(.body)
                                            .foregroundColor(.white.opacity(0.95))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal)
                                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                                            .opacity(contentOpacity)
                                            .animation(.easeOut(duration: 0.3).delay(0.2), value: currentStep)
                                    }
                                    
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            buttonScale = 0.95
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                buttonScale = 1.0
                                            }
                                            nextStep()
                                        }
                                    }) {
                                        Text("Next")
                                            .font(.system(size: 20, weight: .semibold))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 18)
                                            .background(Color.primaryGreen)
                                            .foregroundColor(.black)
                                            .cornerRadius(28)
                                            .scaleEffect(buttonScale)
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
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
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
                                    .scaleEffect(index == currentStep ? 1.3 : 1.0)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: currentStep)
                            }
                        }
                        .padding(.top, 50)
                        .padding(.bottom, 20)
                        
                        TabView(selection: $currentStep) {
                            ForEach(3..<steps.count, id: \.self) { index in
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
                                    if index == 3 {
                                        withAnimation {
                                            isTextFieldFocused = false
                                        }
                                    }
                                }
                                .tag(index)
                            }
                        }
                        .frame(height: currentStep == 3 ? (isTextFieldFocused ? 350 : 500) : 500)
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
                                        Text(currentStep == 3 ? "Continue" : "Next")
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
                .scrollDisabled(currentStep != 3 || !isTextFieldFocused)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: currentStep)
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
        case 3:
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
        case 0, 1, 2: return true
        case 3: return isValidPhoneNumber(phoneNumber)
        default: return true
        }
    }
    
    private func nextStep() {
        isTextFieldFocused = false
        
        withAnimation(.easeOut(duration: 0.2)) {
            contentOpacity = 0
        }
        
        switch currentStep {
        case 0, 1, 2:
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                imageScale = 1.1
                imageOffset = -50
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    currentStep += 1
                    imageScale = 1.0
                    imageOffset = 0
                }
                
                withAnimation(.easeIn(duration: 0.3).delay(0.1)) {
                    contentOpacity = 1
                }
            }
        case 3:
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
        
        UserService.shared.registerUser(phoneNumber: fullPhoneNumber, countryCode: self.selectedCountry.code) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let userId):
                    self.viewModel.saveUserId(userId)
                    
                    self.completeOnboarding()
                    
                    viewModel.showPaywall = true
                    
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

    private func getOnboardingSubtitle(for step: Int) -> String {
        switch step {
        case 0:
            return "Record and transcribe your important\ncalls with ease"
        case 1:
            return "Never miss important details again.\nOur AI captures every word with precision"
        case 2:
            return "Save hours with automated meeting notes.\nFocus on the conversation, not note-taking"
        default:
            return steps[step].subtitle
        }
    }
}

struct OnboardingStep {
    let title: String
    let subtitle: String
    let icon: String
}

