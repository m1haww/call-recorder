import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel = AppViewModel.shared
    
    @State private var phoneNumber = ""
    @State private var selectedCountry = Country.defaultCountry
    @State private var showCountryPicker = false
    @State private var selectedPlan = "free_trial"
    @State private var currentStep = 0
    @State private var showError = false
    @State private var errorMessage = ""
    
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
        ),
        OnboardingStep(
            title: "Choose Your Plan",
            subtitle: "Start with a free trial, then select your subscription",
            icon: "crown.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            Color.darkBackground
                .ignoresSafeArea()
            
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
                    ForEach(0..<steps.count, id: \.self) { index in
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
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onAppear(perform: {
                    UIScrollView.appearance().isScrollEnabled = false
                })
                
                VStack(spacing: 16) {
                    if currentStep < steps.count - 1 {
                        Button(action: nextStep) {
                            Text(currentStep == 1 ? "Continue" : "Next")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(canProceed ? Color.primaryGreen : Color.surfaceBackground)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                        }
                        .disabled(!canProceed)
                        .animation(.easeInOut(duration: 0.2), value: canProceed)
                    } else {
                        Button(action: completeOnboarding) {
                            Text("Get Started")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.primaryGreen)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
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
        case 0:
            VStack {
                Spacer()
            }
            .frame(height: 100)
            
        case 1:
            VStack(spacing: 20) {
                Button(action: {
                    showCountryPicker = true
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
            
        case 2:
            VStack(spacing: 20) {
                // Free Trial Card
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "gift.fill")
                                    .foregroundColor(.primaryGreen)
                                Text("Free Trial")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primaryText)
                            }
                            
                            Text("3 Days Free")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryText)
                            
                            Text("Full access to all features")
                                .font(.caption)
                                .foregroundColor(.secondaryText)
                        }
                        
                        Spacer()
                        
                        if selectedPlan == "free_trial" {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.primaryGreen)
                                .font(.title2)
                        }
                    }
                    .padding()
                    .background(selectedPlan == "free_trial" ? Color.primaryGreen.opacity(0.1) : Color.cardBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedPlan == "free_trial" ? Color.primaryGreen : Color.surfaceBackground, lineWidth: 2)
                    )
                    .onTapGesture {
                        selectedPlan = "free_trial"
                    }
                }
                
                // Subscription Plans
                VStack(spacing: 16) {
                    Text("Then choose your plan:")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                    
                    HStack(spacing: 10) {
                        SubscriptionPlanCard(
                            title: "Weekly",
                            price: "$9",
                            period: "week",
                            isSelected: selectedPlan == "weekly",
                            action: { selectedPlan = "weekly" }
                        )
                        
                        SubscriptionPlanCard(
                            title: "Monthly",
                            price: "$24",
                            period: "month",
                            isSelected: selectedPlan == "monthly",
                            savings: "Save 33%",
                            action: { selectedPlan = "monthly" }
                        )
                        
                        SubscriptionPlanCard(
                            title: "Yearly",
                            price: "$99",
                            period: "year",
                            isSelected: selectedPlan == "yearly",
                            savings: "Save 79%",
                            isPopular: true,
                            action: { selectedPlan = "yearly" }
                        )
                    }
                }
                
                // Features List
                VStack(alignment: .leading, spacing: 12) {
                    FeatureItem(icon: "infinity", text: "Unlimited recordings")
                    FeatureItem(icon: "text.bubble.fill", text: "AI transcriptions")
                    FeatureItem(icon: "icloud.fill", text: "Cloud sync")
                    FeatureItem(icon: "lock.shield.fill", text: "Secure & private")
                }
                .padding(.top, 16)
                
                Text("Cancel anytime. No commitment.")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            
        default:
            EmptyView()
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0: return true
        case 1: return isValidPhoneNumber(phoneNumber)
        case 2: return true
        default: return true
        }
    }
    
    private func nextStep() {
        switch currentStep {
        case 1:
            if isValidPhoneNumber(phoneNumber) {
                withAnimation {
                    currentStep += 1
                }
            } else {
                showError = true
                errorMessage = "Please enter a valid phone number for \(selectedCountry.name)"
            }
        case 2:
            let fullPhoneNumber = selectedCountry.dialCode + phoneNumber
            viewModel.saveUserPhoneNumber(fullPhoneNumber)
            viewModel.saveUserCountry(code: selectedCountry.code, name: selectedCountry.name)
            
            completeOnboarding()
        default:
            withAnimation {
                currentStep += 1
            }
        }
    }
    
    
    private func completeOnboarding() {
        viewModel.completeOnboarding()
    }
    
    private func isValidPhoneNumber(_ number: String) -> Bool {
        // Remove any spaces, dashes, or parentheses
        let cleanedNumber = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        // Basic validation: should be between 7-15 digits for most countries
        return cleanedNumber.count >= 7 && cleanedNumber.count <= 15 && !cleanedNumber.isEmpty
    }
}

struct OnboardingStep {
    let title: String
    let subtitle: String
    let icon: String
}

struct SubscriptionPlanCard: View {
    let title: String
    let price: String
    let period: String
    let isSelected: Bool
    var savings: String? = nil
    var isPopular: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                if isPopular {
                    Text("POPULAR")
                        .font(.system(size: 10))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.primaryGreen)
                        .cornerRadius(6)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primaryText)
                
                Text(price)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                Text("/ \(period)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondaryText)
                
                if let savings = savings {
                    Text(savings)
                        .font(.system(size: 10))
                        .fontWeight(.medium)
                        .foregroundColor(.primaryGreen)
                }
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.primaryGreen)
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .padding(.vertical, 16)
            .background(isSelected ? Color.primaryGreen.opacity(0.1) : Color.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.primaryGreen : Color.surfaceBackground, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FeatureItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.primaryGreen)
                .frame(width: 20)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.primaryText)
            
            Spacer()
        }
    }
}
