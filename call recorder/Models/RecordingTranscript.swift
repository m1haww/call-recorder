import SwiftUI

struct RecordingTranscript: Codable {
    let id: String
    let callId: String
    let status: String?
    let text: String?
    let segments: [TranscriptionSegment]?
    let durationSeconds: Double?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, status, text, segments
        case callId = "call_id"
        case durationSeconds = "duration_seconds"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct TranscriptionSegment: Codable, Identifiable {
    let start: Double
    let end: Double
    let text: String

    var id: String { "\(start)-\(end)" }
}
