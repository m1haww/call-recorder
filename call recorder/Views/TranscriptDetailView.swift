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
    
    private var transcriptSegments: [(speaker: String, text: String, timestamp: String)] {
        guard let transcript = recording.transcript else { return [] }
        
        // Simple segmentation - in a real app, this would come from actual speaker diarization
        let words = transcript.split(separator: " ")
        var segments: [(String, String, String)] = []
        var currentSegment = ""
        var segmentIndex = 0
        
        for (index, word) in words.enumerated() {
            currentSegment += word + " "
            
            // Create segments every 50 words or at sentence ends
            if index % 50 == 49 || word.hasSuffix(".") || word.hasSuffix("?") || word.hasSuffix("!") || index == words.count - 1 {
                let speaker = segmentIndex % 2 == 0 ? "Speaker 1" : "Speaker 2"
                let timestamp = formatTimestamp(Double(segmentIndex) * 15.0)
                segments.append((speaker, currentSegment.trimmingCharacters(in: .whitespaces), timestamp))
                currentSegment = ""
                segmentIndex += 1
            }
        }
        
        return segments
    }
    
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
                            
                            Text(recording.contactName)
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
                            icon: "person.2",
                            value: "2",
                            label: "Speakers",
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
                    Text("Timeline").tag(1)
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
                                VStack(alignment: .leading, spacing: 20) {
                                    ForEach(transcriptSegments.indices, id: \.self) { index in
                                        let segment = transcriptSegments[index]
                                        TranscriptSegmentView(
                                            speaker: segment.speaker,
                                            text: segment.text,
                                            timestamp: segment.timestamp,
                                            searchText: searchText,
                                            isAlternate: index % 2 == 1
                                        )
                                    }
                                }
                                .padding()
                            } else {
                                EmptyTranscriptView()
                                    .padding(.top, 80)
                            }
                        } else {
                            // Timeline View
                            TimelineTranscriptView(segments: transcriptSegments, searchText: searchText)
                                .padding()
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
                    
                    TranscriptActionButton(
                        icon: "square.and.pencil",
                        title: "Note",
                        action: {
                            // Add note functionality
                        }
                    )
                    
                    Divider()
                        .frame(height: 40)
                        .background(Color.surfaceBackground)
                    
                    TranscriptActionButton(
                        icon: "star",
                        title: "Favorite",
                        action: {
                            // Add to favorites
                        }
                    )
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
        output += "Contact: \(recording.contactName)\n"
        output += "Date: \(formatDate(recording.date))\n"
        output += "Duration: \(formatDuration(recording.duration))\n\n"
        output += "Transcript:\n\n"
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

struct TranscriptSegmentView: View {
    let speaker: String
    let text: String
    let timestamp: String
    let searchText: String
    let isAlternate: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Speaker Avatar
            ZStack {
                Circle()
                    .fill(isAlternate ? Color.purple.opacity(0.2) : Color.skyBlue.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Text(speaker.prefix(1))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isAlternate ? .purple : .skyBlue)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(speaker)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isAlternate ? .purple : .skyBlue)
                    
                    Text("• \(timestamp)")
                        .font(.system(size: 12))
                        .foregroundColor(.tertiaryText)
                    
                    Spacer()
                }
                
                Text(text)
                    .font(.system(size: 15))
                    .foregroundColor(.primaryText)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cardBackground.opacity(0.5))
        )
    }
}

struct TimelineTranscriptView: View {
    let segments: [(speaker: String, text: String, timestamp: String)]
    let searchText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(segments.indices, id: \.self) { index in
                HStack(alignment: .top, spacing: 16) {
                    // Timeline
                    VStack(spacing: 0) {
                        Circle()
                            .fill(index % 2 == 0 ? Color.skyBlue : Color.purple)
                            .frame(width: 12, height: 12)
                        
                        if index < segments.count - 1 {
                            Rectangle()
                                .fill(Color.tertiaryText.opacity(0.3))
                                .frame(width: 2, height: 80)
                        }
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 8) {
                        Text(segments[index].timestamp)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.tertiaryText)
                        
                        HStack {
                            Text(segments[index].speaker)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(index % 2 == 0 ? .skyBlue : .purple)
                            Spacer()
                        }
                        
                        Text(segments[index].text)
                            .font(.system(size: 14))
                            .foregroundColor(.primaryText)
                            .lineSpacing(3)
                            .lineLimit(3)
                        
                        if index < segments.count - 1 {
                            Spacer(minLength: 20)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
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