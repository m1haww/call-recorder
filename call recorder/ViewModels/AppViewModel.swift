import SwiftUI
import Combine
#if !os(macOS)
import AVFoundation
#endif

class AppViewModel: ObservableObject {
    @Published var recordings: [Recording] = []
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var hasPermissions = false
    @Published var isRecording = false
    @Published var currentUser: UserType = .free
    @Published var selectedLanguage = "English"
    @Published var notificationsEnabled = true
    @Published var selectedPlan = "monthly"
    @Published var showPermissionAlert = false
    @Published var permissionType: PermissionType = .microphone
    @Published var userPhoneNumber = ""
    @Published var userCountryCode = ""
    @Published var userCountryName = ""
    @Published var isOnboardingComplete = false
    
    // Recording service configuration
    let recordingServiceNumber = "+18885551234" // Replace with your actual service number
    
    enum UserType {
        case free, premium
    }
    
    enum PermissionType {
        case microphone, phone
    }
    
    init() {
        checkPermissions()
        loadUserData()
        
        // Load phone number from current user if authenticated
        if let currentUser = AuthManager.shared.currentUser {
            userPhoneNumber = currentUser.phoneNumber
        }
    }
    
    // Removed loadMockData - recordings will only come from actual user recordings
    
    func checkPermissions() {
        #if !os(macOS)
        let microphoneStatus = AVAudioSession.sharedInstance().recordPermission
        hasPermissions = microphoneStatus == .granted
        
        if microphoneStatus == .undetermined {
            requestMicrophonePermission()
        }
        #else
        hasPermissions = true // For macOS testing
        #endif
    }
    
    func requestMicrophonePermission() {
        #if !os(macOS)
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.hasPermissions = granted
                if !granted {
                    self.showPermissionDenied(.microphone)
                }
            }
        }
        #endif
    }
    
    func showPermissionDenied(_ type: PermissionType) {
        permissionType = type
        showPermissionAlert = true
    }
    
    func deleteRecording(at index: Int) {
        withAnimation {
            recordings.remove(at: index)
        }
        showToast("Recording deleted")
    }
    
    func shareRecording(_ recording: Recording) {
        showToast("Sharing recording...")
    }
    
    func startRecording(phoneNumber: String? = nil) {
        if !hasPermissions {
            showPermissionDenied(.microphone)
            return
        }
        
        if currentUser == .free && recordings.count >= 3 {
            showAlert = true
            alertMessage = "You've reached your recording limit. Upgrade to Premium for unlimited recordings."
            return
        }
        
        isRecording = true
        
        // Call server API to start recording
        startRecordingOnServer(targetNumber: phoneNumber)
    }
    
    private func startRecordingOnServer(targetNumber: String?) {
        guard !userPhoneNumber.isEmpty else {
            showToast("User phone number not set")
            isRecording = false
            return
        }
        
        guard let targetNumber = targetNumber else {
            showToast("Target phone number required")
            isRecording = false
            return
        }
        
        // Call server API to start recording
        let recordingData: [String: Any] = [
            "recording_status": "started",
            "recording_duration": 0,
            "transcription_status": "pending"
        ]
        
        ServerManager.shared.saveCallRecording(
            userPhone: userPhoneNumber,
            targetPhone: targetNumber,
            recordingData: recordingData
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showToast("Recording started on server")
                case .failure(let error):
                    self?.showToast("Failed to start recording: \(error.localizedDescription)")
                    self?.isRecording = false
                }
            }
        }
    }
    
    func refreshRecordings() {
        fetchCallsFromServer()
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
        userPhoneNumber = UserDefaults.standard.string(forKey: "userPhoneNumber") ?? ""
        userCountryCode = UserDefaults.standard.string(forKey: "userCountryCode") ?? ""
        userCountryName = UserDefaults.standard.string(forKey: "userCountryName") ?? ""
        selectedPlan = UserDefaults.standard.string(forKey: "selectedPlan") ?? "free_trial"
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
    
    func fetchCallsFromServer() {
        guard !userPhoneNumber.isEmpty else {
            showToast("Phone number required")
            return
        }
        
        isLoading = true
        
        ServerManager.shared.fetchCallsForUser(phoneNumber: userPhoneNumber) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let jsonArray):
                    self?.recordings = []
                    
                    for item in jsonArray {
                        // Parse each recording from the server data
                        let id = item["id"] as? String ?? UUID().uuidString
                        let callDate = item["call_date"] as? String ?? ""
                        let fromPhone = item["from_phone"] as? String ?? ""
                        let toPhone = item["to_phone"] as? String ?? self?.userPhoneNumber ?? ""
                        let recordingDuration = item["recording_duration"] as? Int ?? 0
                        let recordingStatus = item["recording_status"] as? String ?? ""
                        let recordingUrl = item["recording_url"] as? String
                        let summary = item["summary"] as? String
                        let title = item["title"] as? String
                        let transcriptionStatus = item["transcription_status"] as? String ?? ""
                        let transcriptionText = item["transcription_text"] as? String
                        
                        // Determine contact name from phone number
                        let contactName = title ?? (fromPhone == self?.userPhoneNumber ? toPhone : fromPhone)
                        
                        // Create Recording object
                        let recording = Recording(
                            id: UUID(uuidString: id) ?? UUID(),
                            contactName: contactName,
                            phoneNumber: fromPhone == self?.userPhoneNumber ? toPhone : fromPhone,
                            date: self?.parseDate(callDate) ?? Date(),
                            duration: TimeInterval(recordingDuration),
                            transcript: transcriptionText ?? summary,
                            isUploaded: recordingUrl != nil
                        )
                        
                        self?.recordings.append(recording)
                    }
                    
                    self?.showToast("\(jsonArray.count) recordings loaded")
                    
                case .failure(let error):
                    self?.showToast("Failed to fetch calls: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
}