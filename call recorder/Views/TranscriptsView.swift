import SwiftUI
import UIKit

struct TranscriptsView: View {
    @StateObject var viewModel = AppViewModel.shared
    @StateObject private var subscriptionService = SubscriptionService.shared
    @Binding var navigationPath: NavigationPath
    
    var recordingsWithTranscripts: [Recording] {
        return viewModel.recordings.filter { $0.transcript != nil }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if recordingsWithTranscripts.isEmpty {
                TranscriptEmptyState(isProUser: subscriptionService.isProUser)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(recordingsWithTranscripts) { recording in
                            TranscriptCard(recording: recording, isProUser: subscriptionService.isProUser)
                                .onTapGesture {
                                    HapticManager.shared.impact(.light)
                                    if recording.transcript != nil && !(recording.transcriptText?.isEmpty ?? true) {
                                        viewModel.navigateTo(.transcriptDetail(recording))
                                    } else if !subscriptionService.isProUser {
                                        subscriptionService.showPaywall = true
                                    }
                                }
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 8)
                }
            }}
        .onAppear {
            print(recordingsWithTranscripts.count)
        }
        .background(Color.darkBackground)
        .preferredColorScheme(.dark)
    }
}

struct TranscriptCard: View {
    let recording: Recording
    let isProUser: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recording.contactName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryText)
                    
                    Text(formatDate(recording.date))
                        .font(.system(size: 12))
                        .foregroundColor(.tertiaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.tertiaryText)
                    .font(.system(size: 14))
            }
            
            if let transcriptText = recording.transcriptText, !transcriptText.isEmpty {
                Text(transcriptText)
                    .font(.system(size: 14))
                    .foregroundColor(.secondaryText)
                    .lineLimit(2)
                    .padding(.top, 2)
            } else if !isProUser {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 12))
                    Text(String(localized: "Transcript available with Premium"))
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                        .italic()
                }
                .padding(.top, 2)
            } else {
                Text(String(localized: "Transcript not available"))
                    .font(.system(size: 12))
                    .foregroundColor(.tertiaryText)
                    .italic()
                    .padding(.top, 2)
            }
            
            HStack {
                Label(formatDuration(recording.duration), systemImage: "clock")
                    .font(.system(size: 11))
                    .foregroundColor(.tertiaryText)
                
                Spacer()
                
                if recording.isUploaded {
                    Label(String(localized: "Synced"), systemImage: "checkmark.icloud.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.primaryGreen)
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.surfaceBackground.opacity(0.5), lineWidth: 0.5)
        )
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
