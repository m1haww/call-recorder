import SwiftUI
import UIKit

struct TranscriptDetailView: View {
    let recording: Recording
    @State private var showShareSheet = false
    @State private var copiedToClipboard = false
    @State private var selectedSegment = 0
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack {
                    Text(localizationManager.localizedString("transcript"))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primaryText)
                        .frame(maxWidth: .infinity)
                    
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .medium))
                                Text(localizationManager.localizedString("back"))
                                    .font(.system(size: 17))
                            }
                            .foregroundColor(.skyBlue)
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.darkBackground)
                
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
                            Text(localizationManager.localizedString("call_recording"))
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
                    
                    HStack(spacing: 12) {
                        TranscriptStatCard(
                            icon: "text.word.spacing",
                            value: "\(wordCount)",
                            label: localizationManager.localizedString("words"),
                            color: .skyBlue
                        )
                        
                        TranscriptStatCard(
                            icon: "doc.text",
                            value: recording.summary != nil ? localizationManager.localizedString("yes") : localizationManager.localizedString("no"),
                            label: localizationManager.localizedString("summary"),
                            color: .purple
                        )
                        
                        TranscriptStatCard(
                            icon: "waveform",
                            value: (recording.transcript?.status ?? "") == "completed" ? localizationManager.localizedString("clear_quality") : localizationManager.localizedString("processing"),
                            label: localizationManager.localizedString("quality"),
                            color: .orange
                        )
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.top, 8)
                
                Picker("View Mode", selection: $selectedSegment) {
                    Text(localizationManager.localizedString("full_text")).tag(0)
                    Text(localizationManager.localizedString("summary")).tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top, 8)
                
                ScrollView {
                    VStack(spacing: 0) {
                        if selectedSegment == 0 {
                            if let segments = recording.transcript?.segments, !segments.isEmpty {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(localizationManager.localizedString("transcript"))
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.primaryText)
                                        .padding(.bottom, 12)
                                    
                                    ForEach(segments) { segment in
                                        TranscriptSegmentRow(
                                            startTime: segment.start,
                                            endTime: segment.end,
                                            text: segment.text,
                                            formatTimestamp: formatTimestamp
                                        )
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            } else if let transcriptText = recording.transcriptText, !transcriptText.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text(localizationManager.localizedString("transcript"))
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.primaryText)
                                    
                                    Text(transcriptText)
                                        .font(.system(size: 15))
                                        .foregroundColor(.primaryText)
                                        .lineSpacing(6)
                                        .textSelection(.enabled)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                EmptyTranscriptView(
                                    title: localizationManager.localizedString("transcript_not_available"),
                                    subtitle: localizationManager.localizedString("transcript_processing_unavailable")
                                )
                                    .padding(.top, 80)
                            }
                        } else {
                            if let summary = recording.summary, !summary.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text(localizationManager.localizedString("summary"))
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
                                    
                                    Text(localizationManager.localizedString("no_summary_available"))
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.tertiaryText)
                                    
                                    Text(localizationManager.localizedString("no_summary_message"))
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
                
                HStack(spacing: 0) {
                    TranscriptActionButton(
                        icon: "square.and.arrow.up",
                        title: localizationManager.localizedString("share"),
                        action: { showShareSheet = true }
                    )
                    
                    Divider()
                        .frame(height: 40)
                        .background(Color.surfaceBackground)
                    
                    TranscriptActionButton(
                        icon: copiedToClipboard ? "checkmark" : "doc.on.doc",
                        title: copiedToClipboard ? localizationManager.localizedString("copied") : localizationManager.localizedString("copy"),
                        action: {
                            if let transcriptText = recording.transcriptText {
                                UIPasteboard.general.string = transcriptText
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
            if recording.transcriptText != nil {
                ShareSheet(items: [formatTranscriptForSharing()])
            }
        }
    }
    
    private var wordCount: Int {
        recording.transcriptText?.split(separator: " ").count ?? 0
    }
    
    private func formatTranscriptForSharing() -> String {
        var output = localizationManager.localizedString("share_transcript_header") + "\n"
        output += "========================\n\n"
        output += localizationManager.localizedString("title_label") + ": \(recording.title ?? recording.contactName)\n"
        output += localizationManager.localizedString("contact_label") + ": \(recording.contactName)\n"
        output += localizationManager.localizedString("date") + ": \(formatDate(recording.date))\n"
        output += localizationManager.localizedString("duration") + ": \(formatDuration(recording.duration))\n\n"
        
        if let summary = recording.summary, !summary.isEmpty {
            output += localizationManager.localizedString("summary") + ":\n"
            output += summary + "\n\n"
        }
        
        output += localizationManager.localizedString("full_transcript_label") + ":\n\n"
        output += recording.transcriptText ?? localizationManager.localizedString("transcript_not_available")
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

struct TranscriptSegmentRow: View {
    let startTime: Double
    let endTime: Double
    let text: String
    let formatTimestamp: (Double) -> String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(formatTimestamp(startTime))
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(.secondaryText)
                .frame(width: 44, alignment: .leading)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.primaryText)
                .lineSpacing(5)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
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
    var title: String
    var subtitle: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.bubble")
                .font(.system(size: 60))
                .foregroundColor(.tertiaryText.opacity(0.5))
            
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.tertiaryText)
            
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(.tertiaryText.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
