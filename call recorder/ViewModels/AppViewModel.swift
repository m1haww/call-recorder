import SwiftUI
import Combine
import AVFoundation

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
    
    enum UserType {
        case free, premium
    }
    
    enum PermissionType {
        case microphone, phone
    }
    
    init() {
        loadMockData()
        checkPermissions()
    }
    
    func loadMockData() {
        recordings = [
            Recording(
                contactName: "John Doe",
                phoneNumber: "+1 234-567-8900",
                duration: 125,
                transcript: "Hey John, thanks for calling back. I wanted to discuss the project timeline and make sure we're on track for the upcoming deadline.",
                isUploaded: true
            ),
            Recording(
                contactName: "Jane Smith",
                phoneNumber: "+1 234-567-8901",
                duration: 360,
                transcript: "Hi Jane, I'm following up on our meeting yesterday. The proposal looks great and I think we can move forward with the implementation.",
                isUploaded: false
            ),
            Recording(
                contactName: "Unknown",
                phoneNumber: "+1 234-567-8902",
                duration: 45,
                transcript: nil,
                isUploaded: true
            ),
            Recording(
                contactName: "Mike Johnson",
                phoneNumber: "+1 555-123-4567",
                duration: 240,
                transcript: "Mike, we need to reschedule our appointment for next week. Please let me know what works best for you.",
                isUploaded: true
            )
        ]
    }
    
    func checkPermissions() {
        let microphoneStatus = AVAudioSession.sharedInstance().recordPermission
        hasPermissions = microphoneStatus == .granted
        
        if microphoneStatus == .undetermined {
            requestMicrophonePermission()
        }
    }
    
    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.hasPermissions = granted
                if !granted {
                    self.showPermissionDenied(.microphone)
                }
            }
        }
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
        showToast("Recording started...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isRecording = false
            self.showToast("Recording saved")
        }
    }
    
    func refreshRecordings() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.showToast("Recordings updated")
        }
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
}