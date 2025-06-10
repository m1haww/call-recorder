import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let recording: Recording
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let text = """
        Recording Details:
        Contact: \(recording.contactName)
        Phone: \(recording.phoneNumber)
        Duration: \(formatDuration(recording.duration))
        Date: \(formatDate(recording.date))
        """
        
        var activityItems: [Any] = [text]
        
        if let transcript = recording.transcript {
            let transcriptText = "Transcript:\n\(transcript)"
            activityItems.append(transcriptText)
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .openInIBooks,
            .postToVimeo,
            .postToWeibo,
            .postToFlickr,
            .postToTencentWeibo
        ]
        
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
