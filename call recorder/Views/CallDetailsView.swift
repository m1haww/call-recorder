import SwiftUI
import AVFoundation
import AVKit

struct CallDetailsView: View {
    let recording: Recording
    @Binding var navigationPath: NavigationPath
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @StateObject private var audioPlayer = AudioPlayerManager()
    @State private var showDeleteAlert = false
    @State private var showShareSheet = false
    @State private var isLoadingRecording = false
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var appViewModel: AppViewModel = AppViewModel.shared
    
    var body: some View {
        ZStack {
            Color.darkBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 0) {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(Color.primaryGreen.opacity(0.15))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "phone.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.primaryGreen)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Call Recording")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.primaryText)
                                
                                Text(recording.phoneNumber)
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondaryText)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    
                    HStack(spacing: 12) {
                        StatCard(
                            icon: "calendar",
                            title: "Date",
                            value: formatShortDate(recording.date),
                            color: .primaryGreen
                        )
                        
                        StatCard(
                            icon: "clock",
                            title: "Time",
                            value: formatTime(recording.date),
                            color: .primaryGreen
                        )
                        
                        StatCard(
                            icon: "timer",
                            title: "Duration",
                            value: formatShortDuration(recording.duration),
                            color: .primaryGreen
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 20) {
                        HStack(spacing: 2) {
                            ForEach(0..<30) { _ in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.primaryGreen.opacity(0.3))
                                    .frame(width: 3, height: CGFloat.random(in: 10...40))
                            }
                        }
                        .frame(height: 40)
                        
                        VStack(spacing: 8) {
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.surfaceBackground)
                                        .frame(height: 6)
                                    
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.primaryGreen)
                                        .frame(width: geometry.size.width * audioPlayer.progress, height: 6)
                                }
                            }
                            .frame(height: 6)
                            
                            HStack {
                                Text(formatPlaybackTime(audioPlayer.currentTime))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondaryText)
                                
                                Spacer()
                                
                                Text(formatPlaybackTime(audioPlayer.duration > 0 ? audioPlayer.duration : recording.duration))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondaryText)
                            }
                        }
                        
                        HStack(spacing: 32) {
                            Button(action: {
                                audioPlayer.skip(by: -15)
                            }) {
                                Image(systemName: "gobackward.15")
                                    .font(.system(size: 24))
                                    .foregroundColor(.secondaryText)
                            }
                            
                            Button(action: {
                                Task {
                                    if audioPlayer.isPlaying {
                                        audioPlayer.pause()
                                    } else if !audioPlayer.isInitialized {
                                        isLoadingRecording = true
                                        await audioPlayer.play(recording: recording)
                                        isLoadingRecording = false
                                    } else {
                                        audioPlayer.resume()
                                    }
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.primaryGreen)
                                        .frame(width: 64, height: 64)
                                    
                                    if isLoadingRecording || audioPlayer.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(.white)
                                            .offset(x: audioPlayer.isPlaying ? 0 : 2)
                                    }
                                }
                            }
                            .disabled(isLoadingRecording || audioPlayer.isLoading)
                            
                            Button(action: {
                                audioPlayer.skip(by: 15)
                            }) {
                                Image(systemName: "goforward.15")
                                    .font(.system(size: 24))
                                    .foregroundColor(.secondaryText)
                            }
                        }
                    }
                    .padding(24)
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    HStack(spacing: 12) {
                        DetailActionButton(
                            icon: "square.and.arrow.up",
                            title: "Share",
                            color: .primaryGreen,
                            action: { showShareSheet = true }
                        )
                        
                        DetailActionButton(
                            icon: "trash",
                            title: "Delete",
                            color: .red,
                            action: { showDeleteAlert = true }
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        if let transcript = recording.transcript, !transcript.isEmpty {
                            Button(action: {
                                appViewModel.navigateTo(.transcriptDetail(recording))
                            }) {
                                InfoCard(
                                    icon: "doc.text.fill",
                                    title: "Transcript",
                                    value: "Available",
                                    color: .primaryGreen,
                                    isClickable: true
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if recording.isUploaded {
                            InfoCard(
                                icon: "checkmark.icloud.fill",
                                title: "Cloud Sync",
                                value: "Uploaded",
                                color: .primaryGreen
                            )
                        }
                        
                        InfoCard(
                            icon: "info.circle.fill",
                            title: localized("recording_id"),
                            value: String(recording.id.prefix(8)) + "...",
                            color: .secondaryText
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Recording")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                        Text(localized("back"))
                            .font(.system(size: 17))
                    }
                    .foregroundColor(.primaryGreen)
                }
            }
        }
        .alert("Delete Recording", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await appViewModel.deleteRecording(recording)
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this recording?")
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [recording.recordingUrl ?? URL(string: "https://www.google.com")!])
        }
        .onAppear {
            Task {
                await audioPlayer.preloadRecording(recording: recording)
            }
        }
        .onDisappear {
            audioPlayer.stop()
        }
    }
    
    func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d minutes %d seconds", minutes, seconds)
    }
    
    func formatShortDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%dm %ds", minutes, seconds)
    }
    
    func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    func formatPlaybackTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Components

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.tertiaryText)
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

struct DetailActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(color.opacity(0.1))
                .cornerRadius(12)
        }
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    var isClickable: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primaryText)
            
            if isClickable {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.tertiaryText)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

final class AudioPlayerManager: NSObject, ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var progress: Double = 0
    @Published var duration: TimeInterval = 0
    @Published var isInitialized = false
    @Published var isLoading = false
    @Published var isPreloaded = false
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var preloadedRecording: Recording?
    
    func resume() {
        player?.play()
        isPlaying = true
    }
    
    @MainActor
    func resume(recording: Recording) async {
        if isInitialized && player != nil {
            player?.play()
            isPlaying = true
        } else {
            await play(recording: recording)
        }
    }
    
    @MainActor
    func preloadRecording(recording: Recording) async {
        guard !isPreloaded && preloadedRecording?.id != recording.id else { return }
        
        isLoading = true
        preloadedRecording = recording
        
        guard let url = recording.localFileURL else {
            print("No URL available for recording")
            isLoading = false
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            
            if let playerItem = playerItem {
                while playerItem.status != .readyToPlay && playerItem.status != .failed {
                    try await Task.sleep(nanoseconds: 100_000_000)
                }
                
                if playerItem.status == .readyToPlay {
                    if let assetDuration = try? await playerItem.asset.load(.duration) {
                        if assetDuration.isValid && !assetDuration.isIndefinite {
                            self.duration = CMTimeGetSeconds(assetDuration)
                        }
                    }
                    isPreloaded = true
                    print("Recording preloaded successfully")
                } else {
                    print("Failed to preload recording")
                }
            }
        } catch {
            print("Error preloading recording: \\(error)")
        }
        
        isLoading = false
    }
    
    @MainActor
    func play(recording: Recording) async {
        if isPreloaded && preloadedRecording?.id == recording.id && player != nil {
            setupTimeObserver()
            setupNotificationObserver()
            player?.play()
            isPlaying = true
            isInitialized = true
            return
        }
        
        guard let url = recording.localFileURL else { 
            print("No URL available for recording")
            return 
        }
        
        isLoading = true
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            
            setupTimeObserver()
            setupNotificationObserver()
            
            player?.play()
            isPlaying = true
            isInitialized = true
            
            if let item = playerItem {
                if let assetDuration = try? await item.asset.load(.duration) {
                    if assetDuration.isValid && !assetDuration.isIndefinite {
                        self.duration = CMTimeGetSeconds(assetDuration)
                    }
                }
            }
            
        } catch {
            print("Error setting up audio player: \(error)")
        }
        
        isLoading = false
    }
    
    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor in
                self?.updateProgress(time: time)
            }
        }
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func skip(by seconds: Double) {
        guard let player = player else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + seconds
        let clampedTime = max(0, min(newTime, duration))
        player.seek(to: CMTime(seconds: clampedTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
        currentTime = 0
        progress = 0
        isInitialized = false
        isPreloaded = false
        isLoading = false
        
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        
        NotificationCenter.default.removeObserver(self)
        player = nil
        playerItem = nil
        preloadedRecording = nil
    }
    
    private func updateProgress(time: CMTime) {
        currentTime = CMTimeGetSeconds(time)
        if duration > 0 {
            progress = currentTime / duration
        }
    }
    
    @objc private func playerDidFinishPlaying() {
        Task { @MainActor in
            isPlaying = false
            currentTime = 0
            progress = 0
            isInitialized = false
            player?.seek(to: .zero)
        }
    }
    
    deinit {
        stop()
    }
}

