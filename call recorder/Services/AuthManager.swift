import Foundation
import SwiftUI

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isUserLoggedIn = false
    @Published var currentUser: UserProfile?
    @Published var skipAuthentication = false
    
    private let serverManager = ServerManager.shared
    private let userDefaults = UserDefaults.standard
    
    struct UserProfile {
        let email: String
        let fullName: String
        let phoneNumber: String
        let appleID: String?
        let serverUserID: String?
        
        init(from serverData: [String: Any]) {
            self.email = serverData["email"] as? String ?? ""
            self.fullName = serverData["full_name"] as? String ?? ""
            self.phoneNumber = serverData["phone_number"] as? String ?? ""
            self.appleID = serverData["apple_id"] as? String
            self.serverUserID = serverData["user_id"] as? String ?? serverData["id"] as? String
        }
        
        init(email: String, fullName: String, phoneNumber: String, appleID: String? = nil) {
            self.email = email
            self.fullName = fullName
            self.phoneNumber = phoneNumber
            self.appleID = appleID
            self.serverUserID = nil
        }
    }
    
    init() {
        loadStoredUser()
    }
    
    // MARK: - Authentication Flow
    
    func signUp(email: String, fullName: String, phoneNumber: String, appleID: String? = nil, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        serverManager.registerUser(email: email, fullName: fullName, phoneNumber: phoneNumber, appleID: appleID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userData):
                    let userProfile = UserProfile(from: userData)
                    self?.setCurrentUser(userProfile)
                    completion(.success(userProfile))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func signIn(email: String, phoneNumber: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        serverManager.loginUser(email: email, phoneNumber: phoneNumber) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userData):
                    let userProfile = UserProfile(from: userData)
                    self?.setCurrentUser(userProfile)
                    completion(.success(userProfile))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func signInWithPhoneOnly(phoneNumber: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        serverManager.getUserByPhoneNumber(phoneNumber) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userData):
                    let userProfile = UserProfile(from: userData)
                    self?.setCurrentUser(userProfile)
                    completion(.success(userProfile))
                case .failure:
                    // User not found, create a minimal profile
                    let guestProfile = UserProfile(
                        email: "",
                        fullName: "Guest User",
                        phoneNumber: phoneNumber
                    )
                    self?.setCurrentUser(guestProfile)
                    completion(.success(guestProfile))
                }
            }
        }
    }
    
    func skipAuthenticationFlow() {
        skipAuthentication = true
        isUserLoggedIn = true
        // Create a guest user profile
        currentUser = UserProfile(
            email: "",
            fullName: "Guest User", 
            phoneNumber: ""
        )
        saveUserToDefaults()
    }
    
    func signOut() {
        currentUser = nil
        isUserLoggedIn = false
        skipAuthentication = false
        clearStoredUser()
    }
    
    // MARK: - Private Methods
    
    private func setCurrentUser(_ user: UserProfile) {
        currentUser = user
        isUserLoggedIn = true
        saveUserToDefaults()
    }
    
    private func saveUserToDefaults() {
        guard let user = currentUser else { return }
        
        userDefaults.set(user.email, forKey: "user_email")
        userDefaults.set(user.fullName, forKey: "user_full_name")
        userDefaults.set(user.phoneNumber, forKey: "user_phone_number")
        userDefaults.set(user.appleID, forKey: "user_apple_id")
        userDefaults.set(user.serverUserID, forKey: "user_server_id")
        userDefaults.set(isUserLoggedIn, forKey: "is_user_logged_in")
        userDefaults.set(skipAuthentication, forKey: "skip_authentication")
    }
    
    private func loadStoredUser() {
        let wasLoggedIn = userDefaults.bool(forKey: "is_user_logged_in")
        let shouldSkip = userDefaults.bool(forKey: "skip_authentication")
        
        if wasLoggedIn || shouldSkip {
            let email = userDefaults.string(forKey: "user_email") ?? ""
            let fullName = userDefaults.string(forKey: "user_full_name") ?? "Guest User"
            let phoneNumber = userDefaults.string(forKey: "user_phone_number") ?? ""
            let appleID = userDefaults.string(forKey: "user_apple_id")
            
            currentUser = UserProfile(
                email: email,
                fullName: fullName,
                phoneNumber: phoneNumber,
                appleID: appleID
            )
            isUserLoggedIn = true
            skipAuthentication = shouldSkip
        }
    }
    
    private func clearStoredUser() {
        userDefaults.removeObject(forKey: "user_email")
        userDefaults.removeObject(forKey: "user_full_name")
        userDefaults.removeObject(forKey: "user_phone_number")
        userDefaults.removeObject(forKey: "user_apple_id")
        userDefaults.removeObject(forKey: "user_server_id")
        userDefaults.removeObject(forKey: "is_user_logged_in")
        userDefaults.removeObject(forKey: "skip_authentication")
    }
}