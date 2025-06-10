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
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: callDate) ?? Date()
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
}
