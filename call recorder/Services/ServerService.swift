import Foundation

final class ServerService: ObservableObject {
    static let shared = ServerService()
    
    private let baseURL = "https://call-recorder-api-production-bc8d.up.railway.app"
    
    private init() {}
    
    struct PhoneServiceInfo: Codable {
        let phoneNumber: String
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
        let transcriptionSegments = parseTranscriptionSegments(dictionary["transcription_segments"])

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
            transcriptionText: transcriptionText,
            transcriptionSegments: transcriptionSegments
        )
    }

    private func parseTranscriptionSegments(_ value: Any?) -> [TranscriptionSegment]? {
        guard let array = value as? [[String: Any]], !array.isEmpty else { return nil }
        let segments: [TranscriptionSegment] = array.compactMap { dict in
            guard let start = dict["start"] as? Double ?? (dict["start"] as? Int).map(Double.init),
                  let end = dict["end"] as? Double ?? (dict["end"] as? Int).map(Double.init),
                  let text = dict["text"] as? String else { return nil }
            return TranscriptionSegment(start: start, end: end, text: text)
        }
        return segments.isEmpty ? nil : segments
    }
    
    func fetchCallsForUser(userId: String) async throws -> [Recording] {
        let url = URL(string: "\(baseURL)/get_calls_for_user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0
        
        let body = ["user_id": userId]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, req) = try await safeSession().data(for: request)
            
            if let httpResponse = req as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
            }
            
            if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                let recordings = jsonArray.compactMap { self.createRecording(from: $0, userPhone: "") }
                return recordings
            } else if let _ = try JSONSerialization.jsonObject(with: data) as? [Any] {
                return []
            } else {
                throw ServerError.invalidResponse
            }
        } catch {
            print("Network error: \(error)")
        
            throw error
        }
    }
    
    func deleteRecording(recordingId: String, userId: String) async throws {
        let url = URL(string: "\(baseURL)/delete_recording")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "recording_id": recordingId,
            "user_id": userId
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await safeSession().data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServerError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let errorMessage = String(data: data, encoding: .utf8) {
                print("Delete error: \(errorMessage)")
            }
            throw ServerError.invalidResponse
        }
    }
    
    func deleteAllRecordings(userId: String) async throws {
        let url = URL(string: "\(baseURL)/delete_all_recordings")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0
        
        let body = ["user_id": userId]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await safeSession().data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServerError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let errorMessage = String(data: data, encoding: .utf8) {
                print("Delete all recordings error: \(errorMessage)")
            }
            throw ServerError.invalidResponse
        }
        
        print("Successfully deleted all recordings for user: \(userId)")
    }
    
    func fetchPhoneServiceNumber() async throws -> PhoneServiceInfo {
        let countryCode = Locale.current.region?.identifier ?? "US"
        let url = URL(string: "\(baseURL)/api/service/phone/\(countryCode)")!
        print("User country code: \(countryCode)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30.0
        
        do {
            let (data, response) = try await safeSession().data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ServerError.invalidResponse
            }
            
            if httpResponse.statusCode != 200 {
                throw ServerError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let phoneServiceInfo = try decoder.decode(PhoneServiceInfo.self, from: data)
            print("Fetched phone number: \(phoneServiceInfo.phoneNumber)")
            return phoneServiceInfo
        } catch {
            print("Error fetching phone service number: \(error)")
            throw error
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
