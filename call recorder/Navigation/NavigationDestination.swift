import SwiftUI

enum NavigationDestination: Hashable {
    case callDetails(Recording)
    case transcripts
    case transcriptDetail(Recording)
    case settings
    case recordCall
    case player(Recording)
    
    // Make it Hashable
    func hash(into hasher: inout Hasher) {
        switch self {
        case .callDetails(let recording):
            hasher.combine("callDetails")
            hasher.combine(recording.id)
        case .transcripts:
            hasher.combine("transcripts")
        case .transcriptDetail(let recording):
            hasher.combine("transcriptDetail")
            hasher.combine(recording.id)
        case .settings:
            hasher.combine("settings")
        case .recordCall:
            hasher.combine("recordCall")
        case .player(let recording):
            hasher.combine("player")
            hasher.combine(recording.id)
        }
    }
    
    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        switch (lhs, rhs) {
        case (.callDetails(let lhsRecording), .callDetails(let rhsRecording)):
            return lhsRecording.id == rhsRecording.id
        case (.transcripts, .transcripts):
            return true
        case (.transcriptDetail(let lhsRecording), .transcriptDetail(let rhsRecording)):
            return lhsRecording.id == rhsRecording.id
        case (.settings, .settings):
            return true
        case (.recordCall, .recordCall):
            return true
        case (.player(let lhsRecording), .player(let rhsRecording)):
            return lhsRecording.id == rhsRecording.id
        default:
            return false
        }
    }
}