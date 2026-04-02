import SwiftUI
import Combine
import AVFoundation

final class AppViewModel: ObservableObject {
    static let shared = AppViewModel()
    
    @Published var recordings: [Recording] = []
    
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    @Published var notificationsEnabled = true
    @Published var showPermissionAlert = false
    
    @Published var isOnboardingComplete = false
    @Published var userPhoneNumber: String = ""
    @Published var userCountryCode: String = ""
    
    @Published var isRegistered: Bool = false
    @Published var showPhoneSelection: Bool = false
    @Published var recordingToShare: Recording?
    @Published var recordingServiceNumber: String = ""
    @Published var navigationPath = NavigationPath()
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    
    private let fcmTokenKey = "user_fcm_token"
    private let userIdKey = "user_id"
    
    var userId: String {
        if let id = UserDefaults.standard.string(forKey: userIdKey) {
            return id
        } else {
            let newId = UUID().uuidString
            UserDefaults.standard.set(newId, forKey: userIdKey)
            return newId
        }
    }
    
    var fcmToken: String? {
        return UserDefaults.standard.string(forKey: fcmTokenKey)
    }
    
    func saveFCMToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: fcmTokenKey)
    }
    
    enum UserType {
        case free, premium
    }
    
    func navigateTo(_ destination: NavigationDestination) {
        navigationPath.append(destination)
    }
    
    func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
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
            try await ServerService.shared.deleteRecording(recordingId: recording.id, userId: userId)
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
    
    @MainActor
    func deleteAllRecordings() async {
        guard !userId.isEmpty else {
            showToast("User not logged in")
            return
        }
        
        isLoading = true
        
        do {
            try await ServerService.shared.deleteAllRecordings(userId: userId)
            
            recordings.removeAll()
            showToast("All recordings deleted")
        } catch {
            showToast("Failed to delete all recordings: \(error.localizedDescription)")
        }
        
        isLoading = false
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
    
    func deleteAccount() {
        recordings.removeAll()
        showToast("Account deleted")
    }
    
    @MainActor
    func updatePhoneNumber(newPhoneNumber: String, countryCode: String) async {
        isLoading = true
        
        do {
            let success = try await UserService.shared.updateUserPhoneNumber(userId: self.userId, newPhoneNumber: newPhoneNumber, countryCode: countryCode)
            if success {
                userPhoneNumber = newPhoneNumber
                userCountryCode = countryCode
                showToast("Phone number updated successfully")
            } else {
                showToast("Failed to update phone number")
            }
        } catch {
            showToast("Error updating phone number: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadUserDataFromServer() async {
        guard !userId.isEmpty else {
            print("No userId available to load user data")
            return
        }
        
        do {
            let userData = try await UserService.shared.loadUserData(userId: self.userId)
            
            userPhoneNumber = userData.phoneNumber
            userCountryCode = userData.countryCode
            notificationsEnabled = userData.notificationsEnabled
            
            print("User data loaded successfully")
        } catch {
            print("Failed to load user data: \(error.localizedDescription)")
        }
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
    
    func toggleRegisterStatus() {
        self.isRegistered = true
        UserDefaults.standard.set(true, forKey: "isRegistered")
    }
    
    func loadUserData() {
        self.isOnboardingComplete = UserDefaults.standard.bool(forKey: "isOnboardingComplete")
        self.isRegistered = UserDefaults.standard.bool(forKey: "isRegistered")
        self.userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        self.userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    }
    
    func completeOnboarding() {
        self.isOnboardingComplete = true
        UserDefaults.standard.set(true, forKey: "isOnboardingComplete")
    }
    
    @MainActor
    func fetchCallsFromServerAsync() async {
        guard !userId.isEmpty else {
            showToast("User not logged in")
            return
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        
        do {
            let recordings = try await ServerService.shared.fetchCallsForUser(userId: userId)
            
            if Task.isCancelled {
                isLoading = false
                return
            }
            
            self.recordings = recordings
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
        guard !userId.isEmpty else { return }
        
        do {
            let recordings = try await ServerService.shared.fetchCallsForUser(userId: userId)
        
            if !Task.isCancelled {
                self.recordings = recordings
            }
        } catch {
            if error._code != NSURLErrorCancelled {
                print("Refresh error: \(error.localizedDescription)")
            }
        }
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: dateString)
    }
    
    @MainActor
    func fetchPhoneServiceNumber() async {
        do {
            let phoneService = try await ServerService.shared.fetchPhoneServiceNumber()
            self.recordingServiceNumber = phoneService.phoneNumber
        } catch {
            print("Failed to fetch phone service number: \(error.localizedDescription)")
        }
    }
}
