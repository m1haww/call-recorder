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
    
    @Published var isProUser: Bool = false
    
    @Published var selectedLanguage = "English"
    @Published var notificationsEnabled = true
    @Published var showPermissionAlert = false
    
    @Published var permissionType: PermissionType = .microphone
    @Published var userPhoneNumber = ""
    @Published var userCountryCode = ""
    @Published var userCountryName = ""
    @Published var isOnboardingComplete = false
    
    @Published var recordingToShare: Recording?
    
    let recordingServiceNumber = "+15205935701"
    
    enum UserType {
        case free, premium
    }
    
    enum PermissionType {
        case microphone, phone
    }
    
    init() {
        loadUserData()
    }
    
    func deleteRecording(at index: Int) async {
        guard index < recordings.count else { return }
        let recording = recordings[index]
        
        await MainActor.run {
            _ = withAnimation {
                recordings.remove(at: index)
            }
        }
        
        do {
            try await ServerManager.shared.deleteRecording(recordingId: recording.id, userPhone: userPhoneNumber)
            await MainActor.run {
                showToast("Recording deleted")
            }
        } catch {
            await MainActor.run {
                recordings.insert(recording, at: min(index, recordings.count))
                showToast("Failed to delete recording: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteRecording(_ recording: Recording) async {
        guard let index = recordings.firstIndex(where: { $0.id == recording.id }) else { return }
        await deleteRecording(at: index)
    }
    
    func getShareItems(for recording: Recording) -> [Any] {
        var items: [Any] = []
        
        if let url = recording.recordingUrl, let shareURL = URL(string: url) {
            items.append(shareURL)
        } else if let localURL = recording.localFileURL {
            items.append(localURL)
        }
        
        var shareText = "Call Recording\n"
        shareText += "Title: \(recording.title ?? recording.contactName)\n"
        shareText += "Date: \(formatShareDate(recording.date))\n"
        shareText += "Duration: \(formatShareDuration(recording.duration))\n"
        
        if let transcript = recording.transcript, !transcript.isEmpty {
            shareText += "\nTranscript available"
        }
        
        items.append(shareText)
        
        return items
    }
    
    private func formatShareDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatShareDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
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
        
        guard !isLoading else { return }
        
        isLoading = true
        
        do {
            let recordings = try await ServerManager.shared.fetchCallsForUser(phoneNumber: userPhoneNumber)
            
            if Task.isCancelled {
                isLoading = false
                return
            }
            
            self.recordings = recordings
            
            for rec in recordings {
                print(rec.date)
            }
            showToast("\(recordings.count) recordings loaded")
        } catch {
            if error._code == NSURLErrorCancelled {
                print("Request was cancelled")
            } else {
                showToast("Failed to fetch calls: \(error.localizedDescription)")
            }
        }
        
        isLoading = false
    }
    
    @MainActor
    func refreshRecordings() async {
        guard !userPhoneNumber.isEmpty else { return }
        
        // Don't show loading indicator for refresh
        do {
            let recordings = try await ServerManager.shared.fetchCallsForUser(phoneNumber: userPhoneNumber)
            
            // Only update if not cancelled
            if !Task.isCancelled {
                self.recordings = recordings
            }
        } catch {
            // Silently ignore cancellation errors during refresh
            if error._code != NSURLErrorCancelled {
                print("Refresh error: \(error.localizedDescription)")
            }
        }
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        // Try ISO8601 with fractional seconds first
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        // Try without fractional seconds
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        // Try simple format as fallback
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: dateString)
    }
}
