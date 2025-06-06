import SwiftUI
import UIKit
import AVFoundation

struct RecordingPlayerView: View {
    let recording: Recording
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var showShareSheet = false
    @State private var showTranscript = false
    @Environment(\.dismiss) var dismiss
    
    var progress: Double {
        recording.duration > 0 ? currentTime / recording.duration : 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderSection(recording: recording, dismiss: { dismiss() })
            
            Spacer()
            
            WaveformSection(progress: progress)
            
            TimeSection(
                currentTime: currentTime,
                duration: recording.duration
            )
            
            PlaybackControls(
                isPlaying: $isPlaying,
                onRewind: { rewind() },
                onPlayPause: { togglePlayPause() },
                onForward: { forward() }
            )
            
            Spacer()
            
            ActionButtons(
                onDownload: {},
                onShare: { showShareSheet = true },
                onTranscript: { showTranscript = true }
            )
        }
        .padding()
        .background(Color.lightGrey)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(recording: recording)
        }
        .sheet(isPresented: $showTranscript) {
            TranscriptDetailView(recording: recording, onBack: {
                showTranscript = false
            })
        }
    }
    
    func togglePlayPause() {
        isPlaying.toggle()
        if isPlaying {
            startPlayback()
        } else {
            pausePlayback()
        }
    }
    
    func rewind() {
        currentTime = max(0, currentTime - 15)
    }
    
    func forward() {
        currentTime = min(recording.duration, currentTime + 15)
    }
    
    func startPlayback() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if currentTime < recording.duration && isPlaying {
                currentTime += 0.1
            } else {
                timer.invalidate()
                isPlaying = false
                currentTime = 0
            }
        }
    }
    
    func pausePlayback() {
    }
}

struct HeaderSection: View {
    let recording: Recording
    let dismiss: () -> Void
    
    var body: some View {
        HStack {
            Button(action: dismiss) {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.darkGrey)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white))
                    .shadow(color: Color.black.opacity(0.1), radius: 4)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(recording.contactName)
                    .font(.headline)
                    .foregroundColor(.navyBlue)
                
                Text(formatDate(recording.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "waveform")
                .font(.title3)
                .foregroundColor(.clear)
                .frame(width: 44, height: 44)
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct WaveformSection: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                HStack(spacing: 2) {
                    ForEach(0..<50) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.mediumGrey)
                            .frame(width: 3, height: CGFloat.random(in: 10...40))
                    }
                }
                .frame(maxWidth: .infinity)
                
                HStack(spacing: 2) {
                    ForEach(0..<50) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.skyBlue)
                            .frame(width: 3, height: CGFloat.random(in: 10...40))
                    }
                }
                .frame(width: geometry.size.width * progress)
                .clipped()
            }
        }
        .frame(height: 60)
        .padding(.vertical, 40)
    }
}

struct TimeSection: View {
    let currentTime: TimeInterval
    let duration: TimeInterval
    
    var body: some View {
        HStack {
            Text(formatTime(currentTime))
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(formatTime(duration))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct PlaybackControls: View {
    @Binding var isPlaying: Bool
    let onRewind: () -> Void
    let onPlayPause: () -> Void
    let onForward: () -> Void
    
    var body: some View {
        HStack(spacing: 40) {
            Button(action: onRewind) {
                VStack(spacing: 4) {
                    Image(systemName: "gobackward.15")
                        .font(.title2)
                    Text("15s")
                        .font(.caption2)
                }
                .foregroundColor(.navyBlue)
            }
            
            Button(action: onPlayPause) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.skyBlue)
            }
            
            Button(action: onForward) {
                VStack(spacing: 4) {
                    Image(systemName: "goforward.15")
                        .font(.title2)
                    Text("15s")
                        .font(.caption2)
                }
                .foregroundColor(.navyBlue)
            }
        }
        .padding(.vertical, 20)
    }
}

struct ActionButtons: View {
    let onDownload: () -> Void
    let onShare: () -> Void
    let onTranscript: () -> Void
    
    var body: some View {
        HStack(spacing: 32) {
            ActionButton(
                icon: "arrow.down.circle",
                title: "Download",
                action: onDownload
            )
            
            ActionButton(
                icon: "square.and.arrow.up",
                title: "Share",
                action: onShare
            )
            
            ActionButton(
                icon: "doc.text",
                title: "Transcript",
                action: onTranscript
            )
        }
        .padding(.bottom, 20)
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(.skyBlue)
        }
    }
}


#Preview {
    RecordingPlayerView(
        recording: Recording(
            contactName: "John Doe",
            phoneNumber: "+1 234-567-8900",
            duration: 125
        )
    )
}