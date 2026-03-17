import Foundation

struct UserData {
    let userId: String
    let phoneNumber: String
    let countryCode: String
    let notificationsEnabled: Bool
}

final class UserService {
    static let shared = UserService()
    
    private let baseURL = "https://call-recorder-api-production-bc8d.up.railway.app"
    
    private init() {}
    
    func registerUser(fcmToken: String?, phoneNumber: String, countryCode: String) async throws {
        guard let url = URL(string: "\(baseURL)/api/users/register") else {
            throw UserServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0
        
        var requestBody: [String: Any] = [
            "id": AppViewModel.shared.userId,
            "countryCode": countryCode,
            "phoneNumber": phoneNumber,
        ]
        
        if let token = fcmToken {
            requestBody["fcmToken"] = token
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("📤 Register User Request:")
        
        let (data, response) = try await safeSession().data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📥 Register User Response:")
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
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            print("✅ Registration successful - User ID: \(json["message"] ?? "No message")")
        } else {
            print("❌ Invalid response format")
            throw UserServiceError.invalidResponse
        }
    }
    
    func updateNotificationSettings(userId: String, enabled: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
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
        
        safeSession().dataTask(with: request) { data, response, error in
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
    
    func updateUserPhoneNumber(userId: String, newPhoneNumber: String, countryCode: String) async throws -> Bool {
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
        
        let (_, response) = try await safeSession().data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UserServiceError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            return true
        } else {
            throw UserServiceError.serverError(statusCode: httpResponse.statusCode)
        }
    }
    
    func updateNotificationSettings(userId: String, enabled: Bool) async throws -> Bool {
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
        
        let (_, response) = try await safeSession().data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UserServiceError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            return enabled
        } else {
            throw UserServiceError.serverError(statusCode: httpResponse.statusCode)
        }
    }
    
    func loadUserData(userId: String) async throws -> UserData {
        guard let url = URL(string: "\(baseURL)/api/users/\(userId)") else {
            throw UserServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0
        
        let (data, response) = try await safeSession().data(for: request)
        
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
