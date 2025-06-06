import Foundation

struct Recording: Identifiable, Codable {
    let id: UUID
    let contactName: String
    let phoneNumber: String
    let date: Date
    let duration: TimeInterval
    let fileURL: URL?
    let transcript: String?
    let isUploaded: Bool
    
    init(id: UUID = UUID(), 
         contactName: String, 
         phoneNumber: String, 
         date: Date = Date(), 
         duration: TimeInterval, 
         fileURL: URL? = nil, 
         transcript: String? = nil, 
         isUploaded: Bool = false) {
        self.id = id
        self.contactName = contactName
        self.phoneNumber = phoneNumber
        self.date = date
        self.duration = duration
        self.fileURL = fileURL
        self.transcript = transcript
        self.isUploaded = isUploaded
    }
}