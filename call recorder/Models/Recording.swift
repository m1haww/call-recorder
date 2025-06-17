import Foundation

struct Recording: Identifiable, Codable {
    let id: String
    let callDate: String
    let fromPhone: String
    let toPhone: String
    let recordingDuration: Int
    let recordingStatus: String
    let recordingUrl: String?
    let summary: String?
    let title: String?
    let transcriptionStatus: String
    let transcriptionText: String?
    
    init(id: String = UUID().uuidString,
         callDate: String,
         fromPhone: String,
         toPhone: String,
         recordingDuration: Int,
         recordingStatus: String,
         recordingUrl: String? = nil,
         summary: String? = nil,
         title: String? = nil,
         transcriptionStatus: String,
         transcriptionText: String? = nil) {
        self.id = id
        self.callDate = callDate
        self.fromPhone = fromPhone
        self.toPhone = toPhone
        self.recordingDuration = recordingDuration
        self.recordingStatus = recordingStatus
        self.recordingUrl = recordingUrl
        self.summary = summary
        self.title = title
        self.transcriptionStatus = transcriptionStatus
        self.transcriptionText = transcriptionText
    }
    
    var contactName: String {
        if let title = title, !title.isEmpty {
            return title
        }
        return fromPhone
    }
    
    var phoneNumber: String {
        return fromPhone
    }
    
    var date: Date {
        // Try ISO8601 with fractional seconds first
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let date = formatter.date(from: callDate) {
            return date
        }
        
        // Try without fractional seconds
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = formatter.date(from: callDate) {
            return date
        }
        
        // Try simple format as fallback
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: callDate) {
            return date
        }
        
        // Use ISO8601DateFormatter as last resort
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: callDate) {
            return date
        }
        
        // Default to current date if all parsing fails
        print("Failed to parse date: \(callDate)")
        return Date()
    }
    
    var duration: TimeInterval {
        return TimeInterval(recordingDuration)
    }
    
    var transcript: String? {
        return transcriptionText ?? summary
    }
    
    var isUploaded: Bool {
        return recordingUrl != nil
    }
    
    var localFileURL: URL? {
        // First check if we have a remote URL to use
        if let urlString = recordingUrl, let url = URL(string: urlString) {
            return url
        }
        
        // Otherwise check for local file
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let localPath = documentsPath?.appendingPathComponent("\(id).m4a")
        
        // Check if file exists
        if let path = localPath, FileManager.default.fileExists(atPath: path.path) {
            return path
        }
        
        return nil
    }
}
