import SwiftUI

struct RecordCallView: View {
    @ObservedObject var viewModel = AppViewModel.shared
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text("Incoming Call").tag(0)
                    Text("Outgoing Call").tag(1)
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
                                viewModel.showToast("Loading service number...")
                            } else if viewModel.isProUser {
                                makePhoneCall(to: viewModel.recordingServiceNumber)
                            } else {
                                viewModel.showPaywall = true
                            }
                        }
                    )
                } else {
                    OutgoingCallSection(
                        onStartCall: {
                            HapticManager.shared.impact(.medium)
                            if viewModel.recordingServiceNumber.isEmpty {
                                viewModel.showToast("Loading service number...")
                            } else if viewModel.isProUser {
                                makePhoneCall(to: viewModel.recordingServiceNumber)
                            } else {
                                //TODO: show the paywall
                            }
                        }
                    )
                }
                
                Spacer()
            }
            .navigationTitle("Record Call")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .background(Color.darkBackground)
        }
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
                viewModel.showToast("Unable to make phone call on this device")
            }
        }
    }
}

struct IncomingCallSection: View {
    let onCallService: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "phone.arrow.down.left")
                    .font(.system(size: 60))
                    .foregroundColor(.primaryGreen)
                
                Text("Record Incoming Calls")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                
                Text("When you receive a call, follow these steps:")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 16) {
                InstructionStep(number: "1", text: "Answer the incoming call")
                InstructionStep(number: "2", text: "Tap 'Add Call' on your phone")
                InstructionStep(number: "3", text: "Call our recording service")
                InstructionStep(number: "4", text: "Merge the calls - recording starts automatically")
            }
            .padding(.horizontal, 24)
            
            Button(action: onCallService) {
                HStack {
                    Image(systemName: "phone.fill")
                    Text("Call Our Service")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryGreen)
                .foregroundColor(.white)
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
    let onStartCall: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "phone.arrow.up.right")
                    .font(.system(size: 60))
                    .foregroundColor(.primaryGreen)
                
                Text("Record Outgoing Calls")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                
                Text("Follow these steps to record your call:")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 16) {
                InstructionStep(number: "1", text: "Call our recording service first")
                InstructionStep(number: "2", text: "Tap 'Add Call' on your phone")
                InstructionStep(number: "3", text: "Call the person you want to record")
                InstructionStep(number: "4", text: "Merge the calls - recording starts automatically")
            }
            .padding(.horizontal, 24)
            
            Button(action: onStartCall) {
                HStack {
                    Image(systemName: "phone.fill")
                    Text("Call Our Service")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryGreen)
                .foregroundColor(.white)
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
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.title3)
            
            Text("Recording starts automatically when calls are merged")
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
