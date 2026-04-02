import SwiftUI

struct RecordCallView: View {
    @StateObject private var viewModel = AppViewModel.shared
    @StateObject private var subscriptionService = SubscriptionService.shared

    @State private var selectedTab = 0
    @State private var phoneNumber: String = "1"
    @State private var showContactPicker = false

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text(String(localized: "Incoming Call")).tag(0)
                Text(String(localized: "Outgoing Call")).tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 16)
            .onChange(of: selectedTab) { _ in
                HapticManager.shared.selection()
            }

            if selectedTab == 0 {
                IncomingCallSection(
                    isServiceNumberLoading: viewModel.recordingServiceNumber.isEmpty,
                    onCallService: onCallServiceTapped
                )
            } else {
                OutgoingCallSection(
                    phoneNumber: $phoneNumber,
                    showContactPicker: $showContactPicker,
                    isServiceNumberLoading: viewModel.recordingServiceNumber.isEmpty,
                    onCallService: onCallServiceTapped,
                    onCallNumber: onCallTapped
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(.dark)
        .background(Color.darkBackground)
        .sheet(isPresented: $showContactPicker) {
            ContactPickerView(selectedNumber: $phoneNumber)
        }
    }

    private var cleanedPhoneNumber: String {
        phoneNumber.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "+", with: "")
    }

    private func onCallServiceTapped() {
        HapticManager.shared.impact(.medium)
        if viewModel.recordingServiceNumber.isEmpty {
            viewModel.showToast(String(localized: "Loading service number..."))
            return
        }
        if subscriptionService.isProUser {
            makePhoneCall(to: viewModel.recordingServiceNumber)
        } else {
            subscriptionService.showPaywall = true
        }
    }

    private func onCallTapped() {
        HapticManager.shared.impact(.medium)
        guard !cleanedPhoneNumber.isEmpty else { return }
        if subscriptionService.isProUser {
            makePhoneCall(to: cleanedPhoneNumber)
        } else {
            subscriptionService.showPaywall = true
        }
    }

    private func makePhoneCall(to number: String) {
        guard !number.isEmpty else {
            viewModel.showToast(String(localized: "No phone number"))
            return
        }
        if let phoneURL = URL(string: "tel://\(number)") {
            if UIApplication.shared.canOpenURL(phoneURL) {
                UIApplication.shared.open(phoneURL)
            } else {
                viewModel.showToast(String(localized: "Unable to make phone call on this device"))
            }
        }
    }
}

private struct IncomingCallSection: View {
    let isServiceNumberLoading: Bool
    let onCallService: () -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                Text(String(localized: "When you receive a call, follow these steps:"))
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 16) {
                    InstructionStep(number: "1", text: String(localized: "Answer the incoming call"))
                    InstructionStep(number: "2", text: String(localized: "Open the app and tap the green phone button to call our service"))
                    InstructionStep(number: "3", text: String(localized: "Merge the calls - recording starts automatically"))
                }
                .padding(.horizontal, 24)

                Button(action: onCallService) {
                    HStack(spacing: 10) {
                        Image(systemName: "phone.fill")
                        Text(String(localized: "Call Our Service"))
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isServiceNumberLoading ? Color.primaryGreen.opacity(0.5) : Color.primaryGreen)
                    .foregroundColor(.black)
                    .cornerRadius(14)
                }
                .buttonStyle(.plain)
                .disabled(isServiceNumberLoading)
                .padding(.horizontal, 24)
                .padding(.top, 8)

                WarningBanner()
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 32)
        }
    }
}

private struct OutgoingCallSection: View {
    @Binding var phoneNumber: String
    @Binding var showContactPicker: Bool
    let isServiceNumberLoading: Bool
    let onCallService: () -> Void
    let onCallNumber: () -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                OutgoingStep1Content(
                    isServiceNumberLoading: isServiceNumberLoading,
                    onCallService: onCallService
                )

                OutgoingStep2Content(
                    phoneNumber: $phoneNumber,
                    showContactPicker: $showContactPicker,
                    onCallNumber: onCallNumber
                )

                OutgoingStep3Content()
                
            }
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }
}

private struct OutgoingStep1Content: View {
    let isServiceNumberLoading: Bool
    let onCallService: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(String(localized: "Step 1: Call our recording service first"))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button(action: onCallService) {
                HStack(spacing: 10) {
                    Image(systemName: "phone.fill")
                    Text(String(localized: "Call Our Service"))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isServiceNumberLoading ? Color.primaryGreen.opacity(0.5) : Color.primaryGreen)
                .foregroundColor(.black)
                .cornerRadius(14)
            }
            .buttonStyle(.plain)
            .disabled(isServiceNumberLoading)
            .padding(.horizontal, 24)
        }
    }
}

private struct OutgoingStep2Content: View {
    @Binding var phoneNumber: String
    @Binding var showContactPicker: Bool
    let onCallNumber: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(String(localized: "Step 2: Then return to the app and call the person you need, or pick a contact."))
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 24)
                .padding(.top, 30)
            
            DialPadView(
                phoneNumber: $phoneNumber,
                onCall: onCallNumber,
                onPickContact: { showContactPicker = true }
            )
        }
    }
}

private struct OutgoingStep3Content: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(String(localized: "Step 3: Merge the calls\n\nMerge the two calls together. Recording starts automatically—no extra steps needed."))
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 24)

            Image("iphone-merge")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 280)
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .padding(.top, 18)

            WarningBanner()
                .padding(.horizontal, 24)
                .padding(.top, 12)
        }
    }
}

struct DialPadView: View {
    @Binding var phoneNumber: String
    let onCall: () -> Void
    var onPickContact: (() -> Void)? = nil

    private let keypadRows: [(String, String?)] = [
        ("1", nil),
        ("2", "ABC"),
        ("3", "DEF"),
        ("4", "GHI"),
        ("5", "JKL"),
        ("6", "MNO"),
        ("7", "PQRS"),
        ("8", "TUV"),
        ("9", "WXYZ"),
        ("*", nil),
        ("0", "+"),
        ("#", nil)
    ]

    private var cleanedNumber: String {
        phoneNumber.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "+", with: "")
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                if let onPickContact = onPickContact {
                    Button(action: {
                        HapticManager.shared.selection()
                        onPickContact()
                    }) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondaryText)
                    }
                }

                Text(phoneNumber.isEmpty ? " " : phoneNumber)
                    .font(.system(size: 34, weight: .light))
                    .foregroundColor(.primaryText)
                    .frame(maxWidth: .infinity)

                if !phoneNumber.isEmpty {
                    Button(action: {
                        HapticManager.shared.selection()
                        phoneNumber.removeLast()
                    }) {
                        Image(systemName: "delete.left.fill")
                            .font(.title2)
                            .foregroundColor(.secondaryText)
                    }
                }
            }
            .frame(height: 44)
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)

            VStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(0..<3, id: \.self) { col in
                            let index = row * 3 + col
                            KeypadButton(
                                main: keypadRows[index].0,
                                sub: keypadRows[index].1
                            ) {
                                HapticManager.shared.selection()
                                phoneNumber += keypadRows[index].0
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)

            Button(action: onCall) {
                ZStack {
                    Circle()
                        .fill(cleanedNumber.isEmpty ? Color.primaryGreen.opacity(0.5) : Color.primaryGreen)
                        .frame(width: 70, height: 70)
                    Image(systemName: "phone.fill")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
            .disabled(cleanedNumber.isEmpty)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
    }
}

private struct KeypadButton: View {
    let main: String
    let sub: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Text(main)
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(.primaryText)
                if let sub = sub {
                    Text(sub)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.secondaryText)
                }
            }
            .frame(width: 78, height: 78)
            .background(Circle().fill(Color.cardBackground))
            .overlay(Circle().stroke(Color.surfaceBackground, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct RecordCallTutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0

    private let pageCount = 3

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    TutorialPageView(
                        title: String(localized: "Call our recording service first"),
                        bodyText: String(localized: "Tap \"Call our service\" to dial the recording line. Stay on the call, then return to the app."),
                        assetImageName: "iphone-app"
                    )
                    .tag(0)

                    TutorialPageView(
                        title: String(localized: "Then call the number or pick a contact"),
                        bodyText: String(localized: "Back in the app, enter the phone number on the keypad or tap \"Pick contact\" to choose from your contacts. Then tap the green call button."),
                        assetImageName: "iphone-service"
                    )
                    .tag(1)

                    TutorialPageView(
                        title: String(localized: "Merge the calls"),
                        bodyText: String(localized: "Merge the two calls together. Recording starts automatically—no extra steps needed."),
                        assetImageName: "iphone-merge"
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                HStack(spacing: 8) {
                    ForEach(0..<pageCount, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.primaryGreen : Color.surfaceBackground)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color.darkBackground)
            .navigationTitle(String(localized: "How to record"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.darkBackground, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Done")) {
                        HapticManager.shared.selection()
                        dismiss()
                    }
                    .foregroundColor(.primaryGreen)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct TutorialPageView: View {
    let title: String
    let bodyText: String
    let assetImageName: String

    var body: some View {
        VStack(spacing: 24) {
            Image(assetImageName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 340)

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Text(bodyText)
                .font(.body)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 24)
    }
}

struct InstructionStep: View {
    let number: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.headline)
                .foregroundColor(.black)
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

            Text(String(localized: "Recording starts automatically when calls are merged"))
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
