import Foundation

final class ServerManager: ObservableObject {
    static let shared = ServerManager()
    
    private let baseURL = "https://api-57018476417.europe-west1.run.app"
    
    init() {}
    
    func registerUser(email: String, fullName: String, phoneNumber: String, appleID: String? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/register_user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let userData: [String: Any] = [
            "email": email,
            "full_name": fullName,
            "phone_number": phoneNumber,
            "apple_id": appleID ?? "",
            "created_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: userData)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(ServerError.noData))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(ServerError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func createRecording(from dictionary: [String: Any], userPhone: String) -> Recording? {
        let id = dictionary["id"] as? String ?? UUID().uuidString
        let callDate = dictionary["call_date"] as? String ?? ""
        let fromPhone = dictionary["from_phone"] as? String ?? ""
        let toPhone = dictionary["to_phone"] as? String ?? userPhone
        let recordingDuration = dictionary["recording_duration"] as? Int ?? 0
        let recordingStatus = dictionary["recording_status"] as? String ?? ""
        let recordingUrl = dictionary["recording_url"] as? String
        let summary = dictionary["summary"] as? String
        let title = dictionary["title"] as? String
        let transcriptionStatus = dictionary["transcription_status"] as? String ?? ""
        let transcriptionText = dictionary["transcription_text"] as? String
        
        return Recording(
            id: id,
            callDate: callDate,
            fromPhone: fromPhone,
            toPhone: toPhone,
            recordingDuration: recordingDuration,
            recordingStatus: recordingStatus,
            recordingUrl: recordingUrl,
            summary: summary,
            title: title,
            transcriptionStatus: transcriptionStatus,
            transcriptionText: transcriptionText
        )
    }
    
    func fetchCallsForUser(phoneNumber: String, completion: @escaping (Result<[Recording], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/get_calls_for_user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["user_phone": phoneNumber]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(ServerError.noData))
                return
            }
            
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    let recordings = jsonArray.compactMap { self.createRecording(from: $0, userPhone: phoneNumber) }
                    completion(.success(recordings))
                } else if let _ = try JSONSerialization.jsonObject(with: data) as? [Any] {
                    completion(.success([]))
                } else {
                    completion(.failure(ServerError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchCallsForUser(phoneNumber: String) async throws -> [Recording] {
        let url = URL(string: "\(baseURL)/get_calls_for_user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["user_phone": phoneNumber]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        print("----------------------------------------------")
        print(String(data: data, encoding: .utf8) ?? "No data")
        print("----------------------------------------------")
        
        if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            let recordings = jsonArray.compactMap { self.createRecording(from: $0, userPhone: phoneNumber) }
            return recordings
        } else if let _ = try JSONSerialization.jsonObject(with: data) as? [Any] {
            return []
        } else {
            throw ServerError.invalidResponse
        }
    }
}

enum ServerError: LocalizedError {
    case noData
    case invalidResponse
    case userNotFound
    case registrationFailed
    
    var errorDescription: String? {
        switch self {
        case .noData:
            return "No data received from server"
        case .invalidResponse:
            return "Invalid response from server"
        case .userNotFound:
            return "User not found"
        case .registrationFailed:
            return "Registration failed"
        }
    }
}
