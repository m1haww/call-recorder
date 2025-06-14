import SwiftUI
import UIKit

struct TranscriptsView: View {
    @ObservedObject var viewModel = AppViewModel.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Binding var navigationPath: NavigationPath
    @State private var showSubscriptionPrompt = false
    
    var recordingsWithTranscripts: [Recording] {
        return viewModel.recordings.filter { $0.transcript != nil && !$0.transcript!.isEmpty }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if recordingsWithTranscripts.isEmpty {
                    TranscriptEmptyState(userType: viewModel.currentUser) {
                        showSubscriptionPrompt = true
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
                                            showSubscriptionPrompt = true
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
        .sheet(isPresented: $showSubscriptionPrompt) {
            SubscriptionDetailsView()
        }
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

struct TranscriptDetailView: View {
    let recording: Recording
    @State private var showShareSheet = false
    @State private var copiedToClipboard = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.primaryGreen)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recording.contactName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primaryText)
                        
                        HStack(spacing: 12) {
                            Text(formatDate(recording.date))
                                .font(.system(size: 13))
                                .foregroundColor(.secondaryText)
                            
                            Text(formatDuration(recording.duration))
                                .font(.system(size: 13))
                                .foregroundColor(.primaryGreen)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.cardBackground)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let transcript = recording.transcript, !transcript.isEmpty {
                        Text(transcript)
                            .font(.system(size: 15))
                            .foregroundColor(.primaryText)
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                    } else {
                        Text("No transcript available")
                            .font(.system(size: 15))
                            .foregroundColor(.tertiaryText)
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
                .padding()
            }
            .background(Color.darkBackground)
            
            HStack(spacing: 20) {
                Button(action: {
                    showShareSheet = true
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20))
                        Text("Share")
                            .font(.system(size: 10))
                    }
                }
                .frame(minWidth: 44, minHeight: 44)
                
                Button(action: {
                    if let transcript = recording.transcript {
                        UIPasteboard.general.string = transcript
                        copiedToClipboard = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copiedToClipboard = false
                        }
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: copiedToClipboard ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 20))
                        Text(copiedToClipboard ? "Copied!" : "Copy")
                            .font(.system(size: 10))
                    }
                }
                .frame(minWidth: 44, minHeight: 44)
                
                Spacer()
            }
            .foregroundColor(.primaryGreen)
            .padding()
            .background(Color.cardBackground)
            .overlay(
                Rectangle()
                    .fill(Color.surfaceBackground.opacity(0.5))
                    .frame(height: 0.5),
                alignment: .top
            )
        }
        .navigationTitle("Transcript")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showShareSheet) {
            if let transcript = recording.transcript {
                ShareSheet(items: [transcript])
            }
        }
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
