import SwiftUI

struct RecordCallView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var phoneNumber = ""
    @State private var selectedTab = 0
    @State private var showNumberRequiredAlert = false
    @State private var isRecordingActive = false
    
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
                        isRecordingActive: $isRecordingActive,
                        onCallService: {
                            HapticManager.shared.impact(.medium)
                            viewModel.startRecording()
                            isRecordingActive = true
                        }
                    )
                } else {
                    OutgoingCallSection(
                        phoneNumber: $phoneNumber,
                        isRecordingActive: $isRecordingActive,
                        onStartCall: {
                            if phoneNumber.isEmpty {
                                HapticManager.shared.notification(.error)
                                showNumberRequiredAlert = true
                            } else {
                                HapticManager.shared.impact(.medium)
                                viewModel.startRecording(phoneNumber: phoneNumber)
                                isRecordingActive = true
                            }
                        }
                    )
                }
                
                Spacer()
                
                LegalDisclaimer()
                    .padding()
            }
            .navigationTitle("Record Call")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.lightGrey)
        }
        .alert("Phone Number Required", isPresented: $showNumberRequiredAlert) {
            Button("OK") {}
        } message: {
            Text("Please enter a phone number to start the call.")
        }
        .onChange(of: viewModel.isRecording) { newValue in
            isRecordingActive = newValue
        }
        .overlay(
            Group {
                if isRecordingActive {
                    RecordingActiveOverlay()
                }
            }
        )
    }
}

struct IncomingCallSection: View {
    @Binding var isRecordingActive: Bool
    let onCallService: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "phone.arrow.down.left")
                    .font(.system(size: 60))
                    .foregroundColor(.skyBlue)
                
                Text("Record Incoming Calls")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.navyBlue)
                
                Text("When you receive a call, follow these steps:")
                    .font(.subheadline)
                    .foregroundColor(.darkGrey)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 16) {
                InstructionStep(number: "1", text: "Answer the incoming call")
                InstructionStep(number: "2", text: "Tap 'Add Call' on your phone")
                InstructionStep(number: "3", text: "Call our recording service")
                InstructionStep(number: "4", text: "Merge the calls to start recording")
            }
            .padding(.horizontal, 24)
            
            Button(action: onCallService) {
                HStack {
                    Image(systemName: isRecordingActive ? "phone.fill.arrow.up.right" : "phone.fill")
                    Text(isRecordingActive ? "Recording Active" : "Call Our Service")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isRecordingActive ? Color.green : Color.skyBlue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isRecordingActive)
            .frame(minHeight: 44)
            .padding(.horizontal, 24)
            .padding(.top)
            
            WarningBanner()
                .padding(.horizontal, 24)
        }
    }
}

struct OutgoingCallSection: View {
    @Binding var phoneNumber: String
    @Binding var isRecordingActive: Bool
    let onStartCall: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "phone.arrow.up.right")
                    .font(.system(size: 60))
                    .foregroundColor(.skyBlue)
                
                Text("Record Outgoing Calls")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.navyBlue)
                
                Text("Enter the number you want to call:")
                    .font(.subheadline)
                    .foregroundColor(.darkGrey)
            }
            .padding(.top, 40)
            
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "phone")
                        .foregroundColor(.darkGrey)
                    
                    TextField("Phone number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 12) {
                    InstructionStep(number: "1", text: "We'll dial our recording service first")
                    InstructionStep(number: "2", text: "Then add your desired contact")
                    InstructionStep(number: "3", text: "Merge calls to start recording")
                }
            }
            .padding(.horizontal, 24)
            
            Button(action: onStartCall) {
                HStack {
                    Image(systemName: isRecordingActive ? "phone.fill.arrow.up.right" : "phone.fill")
                    Text(isRecordingActive ? "Recording Active" : "Start Recording Call")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isRecordingActive ? Color.green : (phoneNumber.isEmpty ? Color.gray : Color.skyBlue))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(phoneNumber.isEmpty || isRecordingActive)
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
                .background(Circle().fill(Color.skyBlue))
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.navyBlue)
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
            
            Text("You must merge the call to record")
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

struct LegalDisclaimer: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle")
                .foregroundColor(.secondary)
                .font(.footnote)
            
            Text("Recording laws may vary by location. Please ensure you comply with local regulations.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
    }
}

#Preview {
    RecordCallView()
}