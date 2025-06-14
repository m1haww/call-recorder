import SwiftUI
import Combine
import AVFoundation

final class AppViewModel: ObservableObject {
    static let shared = AppViewModel()
    
    @Published var recordings: [Recording] = []
    
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var hasPermissions = false
    
    @Published var isRecording = false
    @Published var currentUser: UserType = .free
    
    @Published var selectedLanguage = "English"
    @Published var notificationsEnabled = true
    @Published var showPermissionAlert = false
    
    @Published var permissionType: PermissionType = .microphone
    @Published var userPhoneNumber = "+15202445872"
    @Published var userCountryCode = ""
    @Published var userCountryName = ""
    @Published var isOnboardingComplete = false
    
    let recordingServiceNumber = "+15205935701"
    
    enum UserType {
        case free, premium
    }
    
    enum PermissionType {
        case microphone, phone
    }
    
    init() {
        loadUserData()
        checkMicrophonePermission()
        
        // Add sample recording with transcript for testing
        #if DEBUG
        addSampleRecordingWithTranscript()
        #endif
    }
    
    func deleteRecording(at index: Int) {
        _ = withAnimation {
            recordings.remove(at: index)
        }
        showToast("Recording deleted")
    }
    
    func shareRecording(_ recording: Recording) {
        showToast("Sharing recording...")
    }
    
    func showToast(_ message: String) {
        alertMessage = message
        showAlert = true
    }
    
    func upgradeToPremium() {
        currentUser = .premium
        showToast("Upgraded to Premium!")
    }
    
    func logout() {
        recordings.removeAll()
        currentUser = .free
        showToast("Logged out successfully")
    }
    
    func deleteAccount() {
        recordings.removeAll()
        showToast("Account deleted")
    }
    
    func filterRecordings(by filter: String, searchText: String = "") -> [Recording] {
        var filtered = recordings
        
        let calendar = Calendar.current
        let now = Date()
        
        switch filter {
        case "Today":
            filtered = recordings.filter { calendar.isDateInToday($0.date) }
        case "Week":
            filtered = recordings.filter {
                calendar.dateInterval(of: .weekOfYear, for: now)?.contains($0.date) ?? false
            }
        default:
            break
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { recording in
                recording.contactName.localizedCaseInsensitiveContains(searchText) ||
                recording.phoneNumber.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    func loadUserData() {
        userPhoneNumber = UserDefaults.standard.string(forKey: "userPhoneNumber") ?? "+15202445872"
        print("-------------------------------")
        print(userPhoneNumber)
        print("-------------------------------")
        userCountryCode = UserDefaults.standard.string(forKey: "userCountryCode") ?? ""
        userCountryName = UserDefaults.standard.string(forKey: "userCountryName") ?? ""
        isOnboardingComplete = UserDefaults.standard.bool(forKey: "isOnboardingComplete")
    }
    
    func saveUserPhoneNumber(_ phoneNumber: String) {
        userPhoneNumber = phoneNumber
        UserDefaults.standard.set(phoneNumber, forKey: "userPhoneNumber")
    }
    
    func saveUserCountry(code: String, name: String) {
        userCountryCode = code
        userCountryName = name
        UserDefaults.standard.set(code, forKey: "userCountryCode")
        UserDefaults.standard.set(name, forKey: "userCountryName")
    }
    
    func completeOnboarding() {
        isOnboardingComplete = true
        UserDefaults.standard.set(true, forKey: "isOnboardingComplete")
    }
    
    @MainActor
    func fetchCallsFromServerAsync() async {
        guard !userPhoneNumber.isEmpty else {
            showToast("Phone number required")
            return
        }
        
        isLoading = true
        
        do {
            let recordings = try await ServerManager.shared.fetchCallsForUser(phoneNumber: userPhoneNumber)
            self.recordings = recordings
            
            for rec in recordings {
                print(rec.date)
            }
            showToast("\(recordings.count) recordings loaded")
        } catch {
            showToast("Failed to fetch calls: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
    
    func checkMicrophonePermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            hasPermissions = true
        case .denied:
            hasPermissions = false
            permissionType = .microphone
        case .undetermined:
            requestMicrophonePermission()
        @unknown default:
            hasPermissions = false
        }
    }
    
    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.hasPermissions = granted
                if !granted {
                    self?.permissionType = .microphone
                    self?.showPermissionAlert = true
                }
            }
        }
    }
    
    #if DEBUG
    private func addSampleRecordingWithTranscript() {
        let sampleTranscript = """
        So, I wanted to discuss the quarterly report with you. The numbers are looking really good this quarter. We've seen a 15% increase in revenue compared to last quarter, which is fantastic.
        
        That's great news! What were the main drivers behind this growth? I'm particularly interested in understanding which product lines performed the best.
        
        Well, our new product line that we launched in January has been performing exceptionally well. It's already accounting for about 30% of our total revenue. The marketing campaign really paid off, and customer feedback has been overwhelmingly positive.
        
        That's excellent. How about our operational costs? Have we been able to maintain our margins despite the expansion?
        
        Yes, actually our margins have improved slightly. We've implemented some cost-saving measures in our supply chain, and the increased volume has given us better negotiating power with suppliers. Our gross margin is up by 2 percentage points.
        
        This is all very encouraging. What's the outlook for next quarter? Do you think we can maintain this momentum?
        
        I'm cautiously optimistic. We have several new initiatives in the pipeline, and if the market conditions remain favorable, we should be able to maintain similar growth rates. However, we need to keep an eye on the competitive landscape.
        
        Agreed. Let's schedule a follow-up meeting next week to dive deeper into the strategic planning for Q3. Can you prepare a detailed breakdown of the growth drivers and risk factors?
        
        Absolutely. I'll have that ready by Tuesday. Should I include the team leads in the meeting as well?
        
        Yes, please do. Their input will be valuable for our planning. Thanks for the update!
        """
        
        let sampleRecording = Recording(
            id: "sample-001",
            callDate: ISO8601DateFormatter().string(from: Date()),
            fromPhone: "+1234567890",
            toPhone: "+0987654321",
            recordingDuration: 480, // 8 minutes
            recordingStatus: "completed",
            recordingUrl: "https://example.com/sample.m4a",
            summary: "Discussed Q2 performance with 15% revenue growth, new product line success, and improved margins. Planning follow-up for Q3 strategy.",
            title: "John Smith - Q2 Business Review",
            transcriptionStatus: "completed",
            transcriptionText: sampleTranscript
        )
        
        DispatchQueue.main.async {
            self.recordings.insert(sampleRecording, at: 0)
        }
    }
    #endif
}
