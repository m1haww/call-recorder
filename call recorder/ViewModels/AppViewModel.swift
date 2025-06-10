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
    @Published var userPhoneNumber = ""
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
                case .success(let recordings):
                    self?.recordings = recordings
                    self?.showToast("\(recordings.count) recordings loaded")
                    
                case .failure(let error):
                    self?.showToast("Failed to fetch calls: \(error.localizedDescription)")
                }
            }
        }
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
}
