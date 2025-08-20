import Foundation

struct UserData {
    let userId: String
    let phoneNumber: String
    let countryCode: String
    let notificationsEnabled: Bool
}

final class UserService {
    static let shared = UserService()
    
    private let baseURL = "https://call-recorder-api-164860087792.us-central1.run.app"
    
    private init() {}
    
    private let fcmTokenKey = "user_fcm_token"
    private let userIdKey = "user_id"
    
    func saveFCMToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: fcmTokenKey)
        UserDefaults.standard.synchronize()
    }
    
    func getFCMToken() -> String {
        return UserDefaults.standard.string(forKey: fcmTokenKey) ?? "No fcm token was provided"
    }
    
    func saveUserId(_ userId: String) {
        UserDefaults.standard.set(userId, forKey: userIdKey)
        UserDefaults.standard.synchronize()
    }
    
    func getUserId() -> String? {
        return UserDefaults.standard.string(forKey: userIdKey)
    }
    
    func registerUser(phoneNumber: String, countryCode: String) async throws -> String {
        let fcmToken = getFCMToken()
        
        guard let url = URL(string: "\(baseURL)/api/users/register") else {
            throw UserServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0
        
        let requestBody: [String: Any] = [
            "countryCode": countryCode,
            "phoneNumber": phoneNumber,
            "fcmToken": fcmToken
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("📤 Register User Request:")
        print("   URL: \(url)")
        print("   Method: POST")
        print("   Body: \(requestBody)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📥 Register User Response:")
            print("   Status Code: \(httpResponse.statusCode)")
            print("   Headers: \(httpResponse.allHeaderFields)")
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("   Body: \(responseString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UserServiceError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw UserServiceError.serverError(statusCode: httpResponse.statusCode)
        }
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let userId = json["userId"] as? String {
            
            saveUserId(userId)
            
            print("✅ Registration successful - User ID: \(userId)")
            return userId
        } else {
            print("❌ Invalid response format")
            throw UserServiceError.invalidResponse
        }
    }
    
    func registerUser(phoneNumber: String, countryCode: String, completion: @escaping (Result<String, Error>) -> Void) {
        Task {
            do {
                let userId = try await registerUser(phoneNumber: phoneNumber, countryCode: countryCode)
                DispatchQueue.main.async {
                    completion(.success(userId))
                }
            } catch {
                print("❌ Registration error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updateNotificationSettings(enabled: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let userId = getUserId() else {
            completion(.failure(UserServiceError.missingUserId))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/api/users/notifications") else {
            completion(.failure(UserServiceError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "userId": userId,
            "pushNotificationsEnabled": enabled
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(UserServiceError.invalidResponse))
                }
                return
            }
            
            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    completion(.success(enabled))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(UserServiceError.serverError(statusCode: httpResponse.statusCode)))
                }
            }
        }.resume()
    }
    
    func updateUserPhoneNumber(newPhoneNumber: String, countryCode: String) async throws -> Bool {
        guard let userId = getUserId() else {
            throw UserServiceError.missingUserId
        }
        
        guard let url = URL(string: "\(baseURL)/api/users/update-phone") else {
            throw UserServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "userId": userId,
            "phoneNumber": newPhoneNumber,
            "countryCode": countryCode
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UserServiceError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            return true
        } else {
            throw UserServiceError.serverError(statusCode: httpResponse.statusCode)
        }
    }
    
    func updateNotificationSettings(enabled: Bool) async throws -> Bool {
        guard let userId = getUserId() else {
            throw UserServiceError.missingUserId
        }
        
        guard let url = URL(string: "\(baseURL)/api/users/notifications") else {
            throw UserServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "userId": userId,
            "pushNotificationsEnabled": enabled
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UserServiceError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            return enabled
        } else {
            throw UserServiceError.serverError(statusCode: httpResponse.statusCode)
        }
    }
    
    func loadUserData() async throws -> UserData {
        guard let userId = getUserId() else {
            throw UserServiceError.missingUserId
        }
        
        guard let url = URL(string: "\(baseURL)/api/users/\(userId)") else {
            throw UserServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0
        
        print("📤 Load User Data Request:")
        print("   URL: \(url)")
        print("   Method: GET")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📥 Load User Data Response:")
            print("   Status Code: \(httpResponse.statusCode)")
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("   Body: \(responseString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UserServiceError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw UserServiceError.serverError(statusCode: httpResponse.statusCode)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let phoneNumber = json["phoneNumber"] as? String,
              let countryCode = json["countryCode"] as? String else {
            throw UserServiceError.invalidResponse
        }
        
        let notificationsEnabled = json["notificationsEnabled"] as? Bool ?? true
        
        return UserData(
            userId: userId,
            phoneNumber: phoneNumber,
            countryCode: countryCode,
            notificationsEnabled: notificationsEnabled
        )
    }
    
    func loadUserData(completion: @escaping (Result<UserData, Error>) -> Void) {
        Task {
            do {
                let userData = try await loadUserData()
                DispatchQueue.main.async {
                    completion(.success(userData))
                }
            } catch {
                print("❌ Load user data error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: fcmTokenKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
        UserDefaults.standard.synchronize()
    }
}

enum UserServiceError: LocalizedError {
    case missingFCMToken
    case missingUserId
    case invalidURL
    case noData
    case invalidResponse
    case serverError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .missingFCMToken:
            return "FCM token is not available"
        case .missingUserId:
            return "User ID is not available"
        case .invalidURL:
            return "Invalid API URL"
        case .noData:
            return "No data received from server"
        case .invalidResponse:
            return "Invalid response format"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        }
    }
}
