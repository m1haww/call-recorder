import SwiftUI
#if !os(macOS)
import AVFoundation
import Contacts
#endif

struct RecordCallView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var phoneNumber = ""
    @State private var selectedTab = 0
    @State private var showNumberRequiredAlert = false
    @State private var isRecordingActive = false
    @State private var isInCall = false
    @State private var showCallInterface = false
    
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
                            // Call the recording service number
                            makePhoneCall(to: viewModel.recordingServiceNumber)
                            viewModel.startRecording()
                            isRecordingActive = true
                        }
                    )
                } else {
                    if showCallInterface {
                        IOSCallInterface(
                            phoneNumber: phoneNumber,
                            isRecordingActive: $isRecordingActive,
                            onEndCall: {
                                HapticManager.shared.impact(.heavy)
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showCallInterface = false
                                    isInCall = false
                                    isRecordingActive = false
                                }
                            },
                            onMergeCall: {
                                HapticManager.shared.impact(.medium)
                                viewModel.startRecording(phoneNumber: phoneNumber)
                                isRecordingActive = true
                            },
                            onAddCall: {
                                makePhoneCall(to: viewModel.recordingServiceNumber)
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
                                    // Make the actual phone call
                                    makePhoneCall(to: phoneNumber)
                                    // Show iOS call interface
                                    showCallInterface = true
                                    isInCall = true
                                }
                            }
                        )
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Record Call")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .background(Color.darkBackground)
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
    
    private func makePhoneCall(to number: String) {
        // Clean the phone number (remove spaces, dashes, etc.)
        let cleanedNumber = number.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        
        // Create the tel: URL
        if let phoneURL = URL(string: "tel://\(cleanedNumber)") {
            // Check if we can open the URL
            if UIApplication.shared.canOpenURL(phoneURL) {
                UIApplication.shared.open(phoneURL)
            } else {
                viewModel.showToast("Unable to make phone call on this device")
            }
        }
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
                        .foregroundColor(.secondaryText)
                    
                    TextField("Phone number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .foregroundColor(.primaryText)
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.surfaceBackground, lineWidth: 1)
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    InstructionStep(number: "1", text: "Tap call to start the call")
                    InstructionStep(number: "2", text: "Use 'Add Call' to dial recording service")
                    InstructionStep(number: "3", text: "Tap 'Merge' to start recording")
                }
            }
            .padding(.horizontal, 24)
            
            Button(action: onStartCall) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(phoneNumber.isEmpty ? Color.surfaceBackground : Color.primaryGreen)
                    .clipShape(Circle())
                    .shadow(color: phoneNumber.isEmpty ? Color.clear : Color.primaryGreen.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .disabled(phoneNumber.isEmpty)
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
    }
}

struct IOSCallInterface: View {
    let phoneNumber: String
    @Binding var isRecordingActive: Bool
    let onEndCall: () -> Void
    let onMergeCall: () -> Void
    let onAddCall: () -> Void
    
    @State private var callTimer = 0
    @State private var timer: Timer?
    @State private var showAddCall = true
    @State private var isMuted = false
    @State private var isSpeakerOn = false
    @State private var showKeypad = false
    @State private var showContacts = false
    @State private var isFaceTimeActive = false
    @State private var contactsPermissionStatus: CNAuthorizationStatus = CNAuthorizationStatus.notDetermined
    @State private var showContactsPermissionAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Call info section
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Contact avatar
                    Circle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 140, height: 140)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 12) {
                        Text(phoneNumber)
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Text(formatCallTime(callTimer))
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    if isRecordingActive {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                            Text("Recording")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(20)
                    }
                    
                    Spacer()
                }
                .frame(height: geometry.size.height * 0.55)
                
                // Call controls section
                VStack(spacing: 50) {
                // Top row controls
                HStack(spacing: 80) {
                    // Mute button
                    CallButton(
                        icon: isMuted ? "mic.slash.fill" : "mic.fill",
                        backgroundColor: isMuted ? Color.white : Color.white.opacity(0.2),
                        iconColor: isMuted ? Color.black : Color.white,
                        action: {
                            HapticManager.shared.impact(.medium)
                            toggleMicrophone()
                        }
                    )
                    
                    // Keypad button
                    CallButton(
                        icon: "square.grid.3x3.fill",
                        backgroundColor: showKeypad ? Color.white : Color.white.opacity(0.2),
                        iconColor: showKeypad ? Color.black : Color.white,
                        action: {
                            HapticManager.shared.impact(.light)
                            showKeypad.toggle()
                        }
                    )
                    
                    // Speaker button
                    CallButton(
                        icon: isSpeakerOn ? "speaker.wave.3.fill" : "speaker.fill",
                        backgroundColor: isSpeakerOn ? Color.white : Color.white.opacity(0.2),
                        iconColor: isSpeakerOn ? Color.black : Color.white,
                        action: {
                            HapticManager.shared.impact(.medium)
                            toggleSpeaker()
                        }
                    )
                }
                
                // Second row controls
                HStack(spacing: 80) {
                    // Add call button or Merge button
                    if showAddCall {
                        CallButton(
                            icon: "plus",
                            backgroundColor: Color.white.opacity(0.2),
                            iconColor: Color.white,
                            action: {
                                HapticManager.shared.impact(.medium)
                                onAddCall()
                                showAddCall = false
                                // Simulate delay for adding call
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    // Call added, now show merge option
                                }
                            }
                        )
                    } else {
                        // Merge button
                        CallButton(
                            icon: "arrow.triangle.merge",
                            backgroundColor: isRecordingActive ? Color.green : Color.white.opacity(0.2),
                            iconColor: isRecordingActive ? Color.white : Color.white,
                            action: {
                                if !isRecordingActive {
                                    HapticManager.shared.impact(.heavy)
                                    onMergeCall()
                                }
                            }
                        )
                    }
                    
                    // FaceTime button
                    CallButton(
                        icon: isFaceTimeActive ? "video.fill" : "video.slash.fill",
                        backgroundColor: isFaceTimeActive ? Color.green : Color.white.opacity(0.2),
                        iconColor: Color.white,
                        action: {
                            HapticManager.shared.impact(.medium)
                            isFaceTimeActive.toggle()
                        }
                    )
                    
                    // Contacts button
                    CallButton(
                        icon: "person.crop.circle.fill",
                        backgroundColor: showContacts ? Color.white : Color.white.opacity(0.2),
                        iconColor: showContacts ? Color.black : Color.white,
                        action: {
                            HapticManager.shared.impact(.light)
                            requestContactsPermission()
                        }
                    )
                }
                
                    // End call button
                    Button(action: {
                        HapticManager.shared.impact(.heavy)
                        onEndCall()
                    }) {
                        Image(systemName: "phone.down.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .frame(width: 75, height: 75)
                            .background(Color.red)
                            .clipShape(Circle())
                            .shadow(color: Color.red.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                }
                .frame(height: geometry.size.height * 0.45)
                .padding(.horizontal, 20)
                .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.9),
                    Color.black.opacity(0.95),
                    Color.black
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea(.all)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .sheet(isPresented: $showKeypad) {
            CallKeypadView()
        }
        .sheet(isPresented: $showContacts) {
            if #available(iOS 14.0, *) {
                CallContactsView(contactsPermissionStatus: contactsPermissionStatus)
            } else {
                // Fallback for older iOS versions
                VStack {
                    Text("Contacts")
                        .font(.title)
                    Text("Contacts feature requires iOS 14.0 or later")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .alert("Contacts Permission Required", isPresented: $showContactsPermissionAlert) {
            Button("Settings") {
                openAppSettings()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please allow access to contacts in Settings to view your contacts during calls.")
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            callTimer += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatCallTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func toggleMicrophone() {
        isMuted.toggle()
        #if !os(macOS)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.voiceChat, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
        #endif
    }
    
    private func toggleSpeaker() {
        isSpeakerOn.toggle()
        #if !os(macOS)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if isSpeakerOn {
                try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            } else {
                try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
            }
        } catch {
            print("Failed to toggle speaker: \(error)")
        }
        #endif
    }
    
    private func requestContactsPermission() {
        #if !os(macOS)
        let store = CNContactStore()
        contactsPermissionStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch contactsPermissionStatus {
        case .authorized:
            showContacts = true
        case .denied, .restricted:
            showContactsPermissionAlert = true
        case .notDetermined:
            store.requestAccess(for: .contacts) { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        self.contactsPermissionStatus = .authorized
                        self.showContacts = true
                    } else {
                        self.contactsPermissionStatus = .denied
                        self.showContactsPermissionAlert = true
                    }
                }
            }
        @unknown default:
            showContactsPermissionAlert = true
        }
        #else
        // For macOS, just show contacts without permission
        showContacts = true
        #endif
    }
    
    private func openAppSettings() {
        #if !os(macOS)
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
        #endif
    }
}

struct CallButton: View {
    let icon: String
    let backgroundColor: Color
    let iconColor: Color
    let action: () -> Void
    
    init(icon: String, backgroundColor: Color, iconColor: Color = .white, action: @escaping () -> Void) {
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.iconColor = iconColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
                .frame(width: 60, height: 60)
                .background(backgroundColor)
                .clipShape(Circle())
        }
        .scaleEffect(0.95)
        .animation(.easeInOut(duration: 0.1), value: backgroundColor)
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

struct CallKeypadView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var dialedNumber = ""
    
    let keypadButtons = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["*", "0", "#"]
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Text("Keypad")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button("Done") {
                    dismiss()
                }
            }
            .padding()
            
            // Dialed number display
            Text(dialedNumber.isEmpty ? "Enter number" : dialedNumber)
                .font(.title)
                .padding()
                .frame(minHeight: 50)
            
            // Keypad grid
            VStack(spacing: 20) {
                ForEach(keypadButtons, id: \.self) { row in
                    HStack(spacing: 60) {
                        ForEach(row, id: \.self) { key in
                            Button(action: {
                                HapticManager.shared.impact(.light)
                                dialedNumber += key
                            }) {
                                Text(key)
                                    .font(.title)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                    .frame(width: 60, height: 60)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
            }
            
            // Call button
            Button(action: {
                HapticManager.shared.impact(.medium)
                // Simulate DTMF tones
                if !dialedNumber.isEmpty {
                    dialedNumber = ""
                }
            }) {
                Image(systemName: "phone.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.green)
                    .clipShape(Circle())
            }
            .disabled(dialedNumber.isEmpty)
            
            Spacer()
        }
        .padding()
    }
}

struct CallContactsView: View {
    @Environment(\.dismiss) private var dismiss
    let contactsPermissionStatus: CNAuthorizationStatus
    @State private var realContacts: [CNContact] = []
    @State private var isLoading = true
    
    let sampleContacts = [
        "John Smith", "Sarah Johnson", "Mike Davis", "Emily Wilson",
        "David Brown", "Lisa Anderson", "Chris Taylor", "Amanda White"
    ]
    
    var body: some View {
        NavigationView {
            Group {
                if contactsPermissionStatus == .authorized {
                    if isLoading {
                        ProgressView("Loading contacts...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if realContacts.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.badge.exclamationmark")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No contacts found")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(realContacts, id: \.identifier) { contact in
                            ContactRow(contact: contact)
                        }
                    }
                } else {
                    List(sampleContacts, id: \.self) { contact in
                        HStack {
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(String(contact.prefix(1)))
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                )
                            
                            Text(contact)
                                .font(.body)
                            
                            Spacer()
                            
                            Button(action: {
                                HapticManager.shared.impact(.light)
                                // Add contact to call
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Contacts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if contactsPermissionStatus == .authorized {
                loadRealContacts()
            } else {
                isLoading = false
            }
        }
    }
    
    private func loadRealContacts() {
        #if !os(macOS)
        guard contactsPermissionStatus == .authorized else {
            DispatchQueue.main.async {
                self.isLoading = false
            }
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let store = CNContactStore()
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)
            
            var contacts: [CNContact] = []
            
            do {
                try store.enumerateContacts(with: request) { contact, stop in
                    if !contact.phoneNumbers.isEmpty {
                        contacts.append(contact)
                    }
                }
                
                DispatchQueue.main.async {
                    self.realContacts = contacts.sorted { contact1, contact2 in
                        let name1 = "\(contact1.givenName) \(contact1.familyName)".trimmingCharacters(in: .whitespaces)
                        let name2 = "\(contact2.givenName) \(contact2.familyName)".trimmingCharacters(in: .whitespaces)
                        return name1.lowercased() < name2.lowercased()
                    }
                    self.isLoading = false
                }
            } catch {
                print("Error loading contacts: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
        #else
        DispatchQueue.main.async {
            self.isLoading = false
        }
        #endif
    }
}

struct ContactRow: View {
    let contact: CNContact
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(initials)
                        .font(.headline)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(fullName)
                    .font(.body)
                    .fontWeight(.medium)
                
                if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                    Text(phoneNumber)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                HapticManager.shared.impact(.light)
                // Add contact to call
            }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var fullName: String {
        let name = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "Unknown Contact" : name
    }
    
    private var initials: String {
        let first = contact.givenName.isEmpty ? "?" : String(contact.givenName.prefix(1))
        let last = contact.familyName.isEmpty ? "" : String(contact.familyName.prefix(1))
        return "\(first)\(last)".uppercased()
    }
}

#Preview {
    RecordCallView()
}