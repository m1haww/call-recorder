import SwiftUI
import UIKit

struct TranscriptDetailView: View {
    let recording: Recording
    @State private var showShareSheet = false
    @State private var copiedToClipboard = false
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var selectedSegment = 0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .medium))
                            Text("Back")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(.skyBlue)
                    }
                    
                    Spacer()
                    
                    Text("Transcript")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primaryText)
                    
                    Spacer()
                    
                    Button(action: { isSearching.toggle() }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 17))
                            .foregroundColor(.skyBlue)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.darkBackground)
                
                // Recording Info Card
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.primaryGreen.opacity(0.15))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "phone.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.primaryGreen)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Call Recording")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondaryText)
                            
                            Text(recording.title ?? recording.contactName)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primaryText)
                            
                            HStack(spacing: 16) {
                                Label(formatDate(recording.date), systemImage: "calendar")
                                    .font(.system(size: 12))
                                    .foregroundColor(.tertiaryText)
                                
                                Label(formatDuration(recording.duration), systemImage: "clock")
                                    .font(.system(size: 12))
                                    .foregroundColor(.primaryGreen)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Quick Stats
                    HStack(spacing: 12) {
                        TranscriptStatCard(
                            icon: "text.word.spacing",
                            value: "\(wordCount)",
                            label: "Words",
                            color: .skyBlue
                        )
                        
                        TranscriptStatCard(
                            icon: "doc.text",
                            value: recording.summary != nil ? "Yes" : "No",
                            label: "Summary",
                            color: .purple
                        )
                        
                        TranscriptStatCard(
                            icon: "waveform",
                            value: recording.transcriptionStatus == "completed" ? "Clear" : "Processing",
                            label: "Quality",
                            color: .orange
                        )
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Search Bar (shown when searching)
                if isSearching {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.tertiaryText)
                        
                        TextField("Search in transcript", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.primaryText)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.tertiaryText)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.surfaceBackground)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                // View Mode Picker
                Picker("View Mode", selection: $selectedSegment) {
                    Text("Full Text").tag(0)
                    Text("Summary").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Transcript Content
                ScrollView {
                    VStack(spacing: 0) {
                        if selectedSegment == 0 {
                            // Full Text View
                            if let transcript = recording.transcript, !transcript.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Transcript")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.primaryText)
                                    
                                    Text(transcript)
                                        .font(.system(size: 15))
                                        .foregroundColor(.primaryText)
                                        .lineSpacing(6)
                                        .textSelection(.enabled)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                EmptyTranscriptView()
                                    .padding(.top, 80)
                            }
                        } else {
                            // Summary View
                            if let summary = recording.summary, !summary.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Summary")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.primaryText)
                                    
                                    Text(summary)
                                        .font(.system(size: 15))
                                        .foregroundColor(.primaryText)
                                        .lineSpacing(6)
                                        .textSelection(.enabled)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                VStack(spacing: 20) {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 60))
                                        .foregroundColor(.tertiaryText.opacity(0.5))
                                    
                                    Text("No summary available")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.tertiaryText)
                                    
                                    Text("A summary has not been generated for this recording")
                                        .font(.system(size: 14))
                                        .foregroundColor(.tertiaryText.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                }
                                .padding(.top, 80)
                            }
                        }
                    }
                }
                .background(Color.darkBackground)
                
                // Action Bar
                HStack(spacing: 0) {
                    TranscriptActionButton(
                        icon: "square.and.arrow.up",
                        title: "Share",
                        action: { showShareSheet = true }
                    )
                    
                    Divider()
                        .frame(height: 40)
                        .background(Color.surfaceBackground)
                    
                    TranscriptActionButton(
                        icon: copiedToClipboard ? "checkmark" : "doc.on.doc",
                        title: copiedToClipboard ? "Copied!" : "Copy",
                        action: {
                            if let transcript = recording.transcript {
                                UIPasteboard.general.string = transcript
                                copiedToClipboard = true
                                HapticManager.shared.notification(.success)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    copiedToClipboard = false
                                }
                            }
                        }
                    )
                    
                    Divider()
                        .frame(height: 40)
                        .background(Color.surfaceBackground)
                    
                }
                .background(Color.cardBackground)
                .overlay(
                    Rectangle()
                        .fill(Color.surfaceBackground.opacity(0.5))
                        .frame(height: 0.5),
                    alignment: .top
                )
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarHidden(true)
        .sheet(isPresented: $showShareSheet) {
            if recording.transcript != nil {
                ShareSheet(items: [formatTranscriptForSharing()])
            }
        }
    }
    
    private var wordCount: Int {
        recording.transcript?.split(separator: " ").count ?? 0
    }
    
    private func formatTranscriptForSharing() -> String {
        var output = "Call Recording Transcript\n"
        output += "========================\n\n"
        output += "Title: \(recording.title ?? recording.contactName)\n"
        output += "Contact: \(recording.contactName)\n"
        output += "Date: \(formatDate(recording.date))\n"
        output += "Duration: \(formatDuration(recording.duration))\n\n"
        
        if let summary = recording.summary, !summary.isEmpty {
            output += "Summary:\n"
            output += summary + "\n\n"
        }
        
        output += "Full Transcript:\n\n"
        output += recording.transcript ?? "No transcript available"
        return output
    }
    
    private func formatTimestamp(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy 'at' HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct TranscriptStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primaryText)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.surfaceBackground)
        .cornerRadius(12)
    }
}


struct TranscriptActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(title)
                    .font(.system(size: 11))
            }
            .foregroundColor(.primaryGreen)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
}

struct EmptyTranscriptView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.bubble")
                .font(.system(size: 60))
                .foregroundColor(.tertiaryText.opacity(0.5))
            
            Text("No transcript available")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.tertiaryText)
            
            Text("The transcript for this recording is being processed or unavailable")
                .font(.system(size: 14))
                .foregroundColor(.tertiaryText.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
