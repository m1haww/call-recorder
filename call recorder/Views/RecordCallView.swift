import SwiftUI

struct RecordCallView: View {
    @StateObject private var viewModel = AppViewModel.shared
    @StateObject private var subscriptionService = SubscriptionService.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text(localizationManager.localizedString("incoming_call")).tag(0)
                    Text(localizationManager.localizedString("outgoing_call")).tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: selectedTab) { _ in
                    HapticManager.shared.selection()
                }
                
                if selectedTab == 0 {
                    IncomingCallSection(
                        onCallService: {
                            HapticManager.shared.impact(.medium)
                            if viewModel.recordingServiceNumber.isEmpty {
                                viewModel.showToast(localizationManager.localizedString("loading_service_number"))
                            } else if subscriptionService.isProUser {
                                makePhoneCall(to: viewModel.recordingServiceNumber)
                            } else {
                                subscriptionService.showPaywall = true
                            }
                        }
                    )
                } else {
                    OutgoingCallSection(
                        onStartCall: {
                            HapticManager.shared.impact(.medium)
                            if viewModel.recordingServiceNumber.isEmpty {
                                viewModel.showToast(localizationManager.localizedString("loading_service_number"))
                            } else if subscriptionService.isProUser {
                                makePhoneCall(to: viewModel.recordingServiceNumber)
                            } else {
                                subscriptionService.showPaywall = true
                            }
                        }
                    )
                }
                
                Spacer()
            }
            .preferredColorScheme(.dark)
            .background(Color.darkBackground)
        }
        .background(Color.darkBackground)
    }
    
    private func makePhoneCall(to number: String) {
        let cleanedNumber = number.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        
        if let phoneURL = URL(string: "tel://\(cleanedNumber)") {
            if UIApplication.shared.canOpenURL(phoneURL) {
                UIApplication.shared.open(phoneURL)
            } else {
                viewModel.showToast(localizationManager.localizedString("unable_make_call"))
            }
        }
    }
}

struct IncomingCallSection: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    let onCallService: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "phone.arrow.down.left")
                    .font(.system(size: 60))
                    .foregroundColor(.primaryGreen)
                
                Text(localizationManager.localizedString("record_incoming_calls"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                
                Text(localizationManager.localizedString("incoming_steps_intro"))
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 16) {
                InstructionStep(number: "1", text: localizationManager.localizedString("incoming_step_1"))
                InstructionStep(number: "2", text: localizationManager.localizedString("incoming_step_2"))
                InstructionStep(number: "3", text: localizationManager.localizedString("incoming_step_3"))
                InstructionStep(number: "4", text: localizationManager.localizedString("incoming_step_4"))
            }
            .padding(.horizontal, 24)
            
            Button(action: onCallService) {
                HStack {
                    Image(systemName: "phone.fill")
                    Text(localizationManager.localizedString("call_our_service"))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryGreen)
                .foregroundColor(.black)
                .cornerRadius(12)
            }
            .frame(minHeight: 44)
            .padding(.horizontal, 24)
            .padding(.top)
            
            WarningBanner()
                .padding(.horizontal, 24)
        }
    }
}

struct OutgoingCallSection: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    let onStartCall: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "phone.arrow.up.right")
                    .font(.system(size: 60))
                    .foregroundColor(.primaryGreen)
                
                Text(localizationManager.localizedString("record_outgoing_calls"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                
                Text(localizationManager.localizedString("outgoing_steps_intro"))
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 16) {
                InstructionStep(number: "1", text: localizationManager.localizedString("outgoing_step_1"))
                InstructionStep(number: "2", text: localizationManager.localizedString("outgoing_step_2"))
                InstructionStep(number: "3", text: localizationManager.localizedString("outgoing_step_3"))
                InstructionStep(number: "4", text: localizationManager.localizedString("outgoing_step_4"))
            }
            .padding(.horizontal, 24)
            
            Button(action: onStartCall) {
                HStack {
                    Image(systemName: "phone.fill")
                    Text(localizationManager.localizedString("call_our_service"))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryGreen)
                .foregroundColor(.black)
                .cornerRadius(12)
            }
            .frame(minHeight: 44)
            .padding(.horizontal, 24)
            .padding(.top)
            
            WarningBanner()
                .padding(.horizontal, 24)
        }
    }
}

struct InstructionStep: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.primaryGreen))
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primaryText)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

struct WarningBanner: View {
    @StateObject private var localizationManager = LocalizationManager.shared

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.title3)
            
            Text(localizationManager.localizedString("recording_merge_warning"))
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.orange)
            
            Spacer()
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}
