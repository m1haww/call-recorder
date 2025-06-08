import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: AppViewModel
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
            LinearGradient(
                gradient: Gradient(colors: [Color.skyBlue.opacity(0.1), Color.navyBlue.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Circle()
                            .fill(index <= currentStep ? Color.skyBlue : Color.mediumGrey)
                            .frame(width: 12, height: 12)
                            .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Current step content
                VStack(spacing: 30) {
                    Image(systemName: steps[currentStep].icon)
                        .font(.system(size: 80))
                        .foregroundColor(.skyBlue)
                        .id(currentStep)
                        .transition(.scale.combined(with: .opacity))
                    
                    VStack(spacing: 12) {
                        Text(steps[currentStep].title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.navyBlue)
                            .multilineTextAlignment(.center)
                        
                        Text(steps[currentStep].subtitle)
                            .font(.subheadline)
                            .foregroundColor(.darkGrey)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    // Step-specific content
                    stepContent
                }
                .animation(.easeInOut(duration: 0.5), value: currentStep)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    if currentStep < steps.count - 1 {
                        Button(action: nextStep) {
                            Text(currentStep == 1 ? "Continue" : "Next")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(canProceed ? Color.skyBlue : Color.mediumGrey)
                                .foregroundColor(.white)
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
                                .background(Color.skyBlue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    
                    if currentStep > 0 {
                        Button(action: previousStep) {
                            Text("Back")
                                .font(.subheadline)
                                .foregroundColor(.darkGrey)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30) // Reduced from 50 to move button up
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
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 1:
            VStack(spacing: 20) {
                // Country Selector
                Button(action: {
                    showCountryPicker = true
                }) {
                    HStack {
                        Text(selectedCountry.shortDisplayName)
                            .font(.title3)
                            .foregroundColor(.navyBlue)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.darkGrey)
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.mediumGrey, lineWidth: 1)
                    )
                }
                
                // Phone Number Input
                HStack(spacing: 0) {
                    Text(selectedCountry.dialCode)
                        .font(.title3)
                        .foregroundColor(.darkGrey)
                        .padding(.leading, 16)
                        .padding(.vertical, 16)
                    
                    TextField("Phone number", text: $phoneNumber)
                        .font(.title3)
                        .padding(.trailing, 16)
                        .padding(.vertical, 16)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                }
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(showError ? Color.red : Color.mediumGrey, lineWidth: 1)
                )
                
                Text("Enter your phone number without the country code")
                    .font(.caption)
                    .foregroundColor(.darkGrey)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 30)
            
        case 2:
            VStack(spacing: 16) { // Reduced spacing from 20 to 16
                // Free Trial Card
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "gift.fill")
                                    .foregroundColor(.skyBlue)
                                Text("Free Trial")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.navyBlue)
                            }
                            
                            Text("3 Days Free")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.navyBlue)
                            
                            Text("Full access to all features")
                                .font(.caption)
                                .foregroundColor(.darkGrey)
                        }
                        
                        Spacer()
                        
                        if selectedPlan == "free_trial" {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.skyBlue)
                                .font(.title2)
                        }
                    }
                    .padding()
                    .background(selectedPlan == "free_trial" ? Color.skyBlue.opacity(0.1) : Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedPlan == "free_trial" ? Color.skyBlue : Color.mediumGrey, lineWidth: 2)
                    )
                    .onTapGesture {
                        selectedPlan = "free_trial"
                    }
                }
                
                // Subscription Plans
                VStack(spacing: 12) {
                    Text("Then choose your plan:")
                        .font(.subheadline)
                        .foregroundColor(.darkGrey)
                    
                    HStack(spacing: 12) {
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
                VStack(spacing: 8) {
                    FeatureItem(icon: "infinity", text: "Unlimited recordings")
                    FeatureItem(icon: "text.bubble.fill", text: "AI transcriptions")
                    FeatureItem(icon: "icloud.fill", text: "Cloud sync")
                    FeatureItem(icon: "lock.shield.fill", text: "Secure & private")
                }
                .padding(.top, 8)
                
                Text("Cancel anytime. No commitment.")
                    .font(.caption)
                    .foregroundColor(.darkGrey)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, -20) // Reduce bottom padding to move button up
            
        default:
            EmptyView()
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0: return true
        case 1: return isValidPhoneNumber(phoneNumber)
        case 2: return true // Always allow proceeding from subscription step
        default: return true
        }
    }
    
    private func nextStep() {
        switch currentStep {
        case 1:
            if isValidPhoneNumber(phoneNumber) {
                let fullPhoneNumber = selectedCountry.dialCode + phoneNumber
                viewModel.saveUserPhoneNumber(fullPhoneNumber)
                viewModel.saveUserCountry(code: selectedCountry.code, name: selectedCountry.name)
                withAnimation {
                    currentStep += 1
                }
            } else {
                showError = true
                errorMessage = "Please enter a valid phone number for \(selectedCountry.name)"
            }
        case 2:
            // Save selected subscription plan
            viewModel.selectedPlan = selectedPlan
            UserDefaults.standard.set(selectedPlan, forKey: "selectedPlan")
            completeOnboarding()
        default:
            withAnimation {
                currentStep += 1
            }
        }
    }
    
    private func previousStep() {
        withAnimation {
            currentStep -= 1
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
            VStack(spacing: 8) {
                if isPopular {
                    Text("POPULAR")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.skyBlue)
                        .cornerRadius(8)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.navyBlue)
                
                Text(price)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.navyBlue)
                
                Text("/ \(period)")
                    .font(.caption2)
                    .foregroundColor(.darkGrey)
                
                if let savings = savings {
                    Text(savings)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.skyBlue)
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.skyBlue.opacity(0.1) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.skyBlue : Color.mediumGrey, lineWidth: isSelected ? 2 : 1)
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
                .foregroundColor(.skyBlue)
                .frame(width: 20)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.navyBlue)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppViewModel())
}