import Foundation

final class UserService {
    static let shared = UserService()
    
    private let baseURL = "https://api-57018476417.europe-west1.run.app"
    
    private init() {}
    
    private let fcmTokenKey = "user_fcm_token"
    private let userIdKey = "user_id"
    private let phoneNumberKey = "user_phone_number"
    
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
    
    func savePhoneNumber(_ phoneNumber: String) {
        UserDefaults.standard.set(phoneNumber, forKey: phoneNumberKey)
        UserDefaults.standard.synchronize()
    }
    
    func getPhoneNumber() -> String? {
        return UserDefaults.standard.string(forKey: phoneNumberKey)
    }
    
    func registerUser(phoneNumber: String) async throws -> String {
        let fcmToken = getFCMToken()
        
        guard let url = URL(string: "\(baseURL)/api/users/register") else {
            throw UserServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0
        
        let requestBody: [String: Any] = [
            "phoneNumber": phoneNumber,
            "fcmToken": fcmToken
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("📤 Register User Request:")
        print("   URL: \(url)")
        print("   Method: POST")
        print("   Body: \(requestBody)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Log response details
        if let httpResponse = response as? HTTPURLResponse {
            print("📥 Register User Response:")
            print("   Status Code: \(httpResponse.statusCode)")
            print("   Headers: \(httpResponse.allHeaderFields)")
        }
        
        // Log response data
        if let responseString = String(data: data, encoding: .utf8) {
            print("   Body: \(responseString)")
        }
        
        // Check status code
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UserServiceError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw UserServiceError.serverError(statusCode: httpResponse.statusCode)
        }
        
        // Parse response
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let userId = json["userId"] as? String {
            
            saveUserId(userId)
            savePhoneNumber(phoneNumber)
            
            print("✅ Registration successful - User ID: \(userId)")
            return userId
        } else {
            print("❌ Invalid response format")
            throw UserServiceError.invalidResponse
        }
    }
    
    // Keep the completion handler version for backward compatibility
    func registerUser(phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
        Task {
            do {
                let userId = try await registerUser(phoneNumber: phoneNumber)
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
    
    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: fcmTokenKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
        UserDefaults.standard.removeObject(forKey: phoneNumberKey)
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
