import SwiftUI
import UIKit

struct TranscriptsView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedRecording: Recording?
    @State private var isLoadingTranscript = false
    @State private var showTranscriptUnavailable = false
    @State private var showSubscriptionPrompt = false
    
    let languages = ["English", "Spanish", "French", "German", "Chinese", "Japanese"]
    
    var recordingsWithTranscripts: [Recording] {
        if viewModel.currentUser == .premium {
            return viewModel.recordings
        } else {
            return viewModel.recordings.filter { $0.transcript != nil }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                LanguagePicker(selectedLanguage: $viewModel.selectedLanguage, languages: languages)
                    .padding()
                
                if let selectedRecording = selectedRecording {
                    TranscriptDetailView(recording: selectedRecording, onBack: {
                        HapticManager.shared.impact(.light)
                        self.selectedRecording = nil
                    })
                } else {
                    if recordingsWithTranscripts.isEmpty {
                        TranscriptEmptyState(userType: viewModel.currentUser) {
                            showSubscriptionPrompt = true
                        }
                    } else {
                        TranscriptsList(
                            recordings: recordingsWithTranscripts,
                            userType: viewModel.currentUser,
                            onSelect: { recording in
                                HapticManager.shared.impact(.light)
                                if recording.transcript == nil && viewModel.currentUser == .free {
                                    showSubscriptionPrompt = true
                                } else if recording.transcript == nil {
                                    isLoadingTranscript = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        isLoadingTranscript = false
                                        showTranscriptUnavailable = true
                                    }
                                } else {
                                    selectedRecording = recording
                                }
                            }
                        )
                    }
                }
            }
            .navigationTitle("Transcripts")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.lightGrey)
        }
        .sheet(isPresented: $showSubscriptionPrompt) {
            SubscriptionDetailsView(selectedPlan: $viewModel.selectedPlan)
        }
        .alert("Transcript Unavailable", isPresented: $showTranscriptUnavailable) {
            Button("Try Again") {
                isLoadingTranscript = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isLoadingTranscript = false
                    viewModel.showToast("Transcription generated!")
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The transcript for this recording is not available yet. Would you like to try generating it now?")
        }
        .overlay(
            Group {
                if isLoadingTranscript {
                    TranscriptLoadingView()
                }
            }
        )
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

struct TranscriptsList: View {
    let recordings: [Recording]
    let userType: AppViewModel.UserType
    let onSelect: (Recording) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(recordings) { recording in
                    TranscriptCard(recording: recording, userType: userType)
                        .onTapGesture {
                            onSelect(recording)
                        }
                        .padding(.horizontal)
                }
            }
            .padding(.top, 8)
        }
    }
}

struct TranscriptCard: View {
    let recording: Recording
    let userType: AppViewModel.UserType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recording.contactName)
                        .font(.headline)
                        .foregroundColor(.navyBlue)
                    
                    Text(formatDate(recording.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.darkGrey)
                    .font(.caption)
            }
            
            if let transcript = recording.transcript {
                Text(transcript)
                    .font(.subheadline)
                    .foregroundColor(.darkGrey)
                    .lineLimit(2)
                    .padding(.top, 4)
            } else if userType == .free {
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("Transcript available with Premium")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .italic()
                }
                .padding(.top, 4)
            } else {
                Text("Transcript not available")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.top, 4)
            }
            
            HStack {
                Label(formatDuration(recording.duration), systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if recording.isUploaded {
                    Label("Synced", systemImage: "checkmark.icloud")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
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

struct TranscriptDetailView: View {
    let recording: Recording
    let onBack: () -> Void
    
    let mockConversation = [
        TranscriptMessage(speaker: "You", text: "Hey John, thanks for calling back.", timestamp: Date()),
        TranscriptMessage(speaker: "John Doe", text: "No problem! What's up?", timestamp: Date().addingTimeInterval(5)),
        TranscriptMessage(speaker: "You", text: "I wanted to discuss the project timeline. We need to move the deadline up by two weeks.", timestamp: Date().addingTimeInterval(10)),
        TranscriptMessage(speaker: "John Doe", text: "Two weeks earlier? That's going to be tight. Let me check with my team.", timestamp: Date().addingTimeInterval(20)),
        TranscriptMessage(speaker: "You", text: "I understand it's challenging, but the client has moved up their launch date.", timestamp: Date().addingTimeInterval(30))
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.skyBlue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(recording.contactName)
                        .font(.headline)
                        .foregroundColor(.navyBlue)
                    
                    Text(formatDate(recording.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(mockConversation) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            HStack(spacing: 16) {
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                }
                
                Button(action: {}) {
                    Image(systemName: "doc.on.doc")
                        .font(.title3)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text("Highlight Important")
                        .font(.footnote)
                        .fontWeight(.medium)
                }
            }
            .foregroundColor(.skyBlue)
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: -2)
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TranscriptMessage: Identifiable {
    let id = UUID()
    let speaker: String
    let text: String
    let timestamp: Date
}

struct MessageBubble: View {
    let message: TranscriptMessage
    
    var isYou: Bool {
        message.speaker == "You"
    }
    
    var body: some View {
        HStack {
            if isYou { Spacer() }
            
            VStack(alignment: isYou ? .trailing : .leading, spacing: 4) {
                Text(message.speaker)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isYou ? .skyBlue : .navyBlue)
                
                Text(message.text)
                    .font(.subheadline)
                    .padding(12)
                    .background(isYou ? Color.skyBlue : Color.mediumGrey)
                    .foregroundColor(isYou ? .white : .navyBlue)
                    .cornerRadius(16)
                
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 300, alignment: isYou ? .trailing : .leading)
            
            if !isYou { Spacer() }
        }
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    TranscriptsView()
}