import SwiftUI
import UIKit
import SuperwallKit

struct TranscriptsView: View {
    @ObservedObject var viewModel = AppViewModel.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Binding var navigationPath: NavigationPath
    
    var recordingsWithTranscripts: [Recording] {
        return viewModel.recordings.filter { $0.transcript != nil && !$0.transcript!.isEmpty }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if recordingsWithTranscripts.isEmpty {
                    TranscriptEmptyState(userType: viewModel.isProUser ? .premium : .free) {
                        Superwall.shared.register(placement: "campaign_trigger")
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(recordingsWithTranscripts) { recording in
                                TranscriptCard(recording: recording, userType: viewModel.currentUser)
                                    .onTapGesture {
                                        HapticManager.shared.impact(.light)
                                        if recording.transcript != nil && !recording.transcript!.isEmpty {
                                            navigationPath.append(NavigationDestination.transcriptDetail(recording))
                                        } else if viewModel.currentUser == .free {
                                            Superwall.shared.register(placement: "campaign_trigger")
                                        }
                                    }
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top, 8)
                    }
                }}
            .navigationTitle(localized("transcripts"))
            .navigationBarTitleDisplayMode(.large)
            .background(Color.darkBackground)
        }
        .preferredColorScheme(.dark)
    }
}

struct LanguagePicker: View {
    @Binding var selectedLanguage: String
    let languages: [String]
    
    var body: some View {
        HStack {
            Image(systemName: "globe")
                .foregroundColor(.skyBlue)
            
            Picker("Language", selection: $selectedLanguage) {
                ForEach(languages, id: \.self) { language in
                    Text(language).tag(language)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .tint(.navyBlue)
            .onChange(of: selectedLanguage) { _ in
                HapticManager.shared.selection()
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
}


struct TranscriptCard: View {
    let recording: Recording
    let userType: AppViewModel.UserType
    
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
            
            if let transcript = recording.transcript {
                Text(transcript)
                    .font(.system(size: 14))
                    .foregroundColor(.secondaryText)
                    .lineLimit(2)
                    .padding(.top, 2)
            } else if userType == .free {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 12))
                    Text("Transcript available with Premium")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                        .italic()
                }
                .padding(.top, 2)
            } else {
                Text("Transcript not available")
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
                    Label("Synced", systemImage: "checkmark.icloud.fill")
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

