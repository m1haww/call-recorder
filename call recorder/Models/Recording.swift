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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let date = formatter.date(from: callDate) {
            return date
        }
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = formatter.date(from: callDate) {
            return date
        }
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: callDate) {
            return date
        }
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: callDate) {
            return date
        }
        
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
        if let urlString = recordingUrl, let url = URL(string: urlString) {
            return url
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let localPath = documentsPath?.appendingPathComponent("\(id).m4a")
        
        if let path = localPath, FileManager.default.fileExists(atPath: path.path) {
            return path
        }
        
        return nil
    }
}
