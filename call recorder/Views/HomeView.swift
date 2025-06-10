import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel = AppViewModel.shared
    
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    @State private var selectedRecording: Recording?
    @State private var showPlayer = false
    @State private var showDeleteAlert = false
    @State private var recordingToDelete: Recording?
    @State private var showShareSheet = false
    @State private var recordingToShare: Recording?
    
    let filters = ["All", "Today", "Week"]
    
    var filteredRecordings: [Recording] {
        viewModel.filterRecordings(by: selectedFilter, searchText: searchText)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                FilterBar(selectedFilter: $selectedFilter, filters: filters)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                if filteredRecordings.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredRecordings) { recording in
                                RecordingCard(
                                    recording: recording,
                                    onPlay: {
                                        HapticManager.shared.impact(.light)
                                        selectedRecording = recording
                                        showPlayer = true
                                    },
                                    onShare: {
                                        HapticManager.shared.impact(.light)
                                        recordingToShare = recording
                                        showShareSheet = true
                                    },
                                    onDelete: {
                                        HapticManager.shared.impact(.medium)
                                        recordingToDelete = recording
                                        showDeleteAlert = true
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .refreshable {
                        await viewModel.fetchCallsFromServerAsync()
                    }
                }
            }
            .navigationTitle("Recordings")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .background(Color.darkBackground)
        }
        .fullScreenCover(isPresented: $showPlayer) {
            if let recording = selectedRecording {
                RecordingPlayerView(recording: recording)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let recording = recordingToShare {
                ShareSheet(recording: recording)
            }
        }
        .alert("Delete Recording", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let recording = recordingToDelete,
                   let index = viewModel.recordings.firstIndex(where: { $0.id == recording.id }) {
                    HapticManager.shared.notification(.warning)
                    viewModel.deleteRecording(at: index)
                }
            }
        } message: {
            Text("Are you sure you want to delete this recording? This action cannot be undone.")
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    LoadingView()
                }
            }
        )
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondaryText)
            
            TextField("Search recordings...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.primaryText)
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.surfaceBackground, lineWidth: 1)
        )
    }
}

struct FilterBar: View {
    @Binding var selectedFilter: String
    let filters: [String]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(filters, id: \.self) { filter in
                FilterButton(
                    title: filter,
                    isSelected: selectedFilter == filter,
                    action: { selectedFilter = filter }
                )
            }
            Spacer()
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.selection()
            action()
        }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? .black : .primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.primaryGreen : Color.cardBackground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.surfaceBackground, lineWidth: 1)
                )
        }
        .frame(minWidth: 44, minHeight: 44)
    }
}

struct RecordingCard: View {
    let recording: Recording
    var onPlay: () -> Void = {}
    var onShare: () -> Void = {}
    var onDelete: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recording.contactName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryText)
                    
                    Text(recording.phoneNumber)
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                if recording.isUploaded {
                    Image(systemName: "checkmark.icloud")
                        .foregroundColor(.primaryGreen)
                        .font(.footnote)
                }
            }
            
            HStack {
                Label(formatDate(recording.date), systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.tertiaryText)
                
                Spacer()
                
                Text(formatDuration(recording.duration))
                    .font(.caption)
                    .foregroundColor(.tertiaryText)
            }
            
            Divider()
                .background(Color.surfaceBackground)
            
            HStack(spacing: 20) {
                Button(action: onPlay) {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(.primaryGreen)
                }
                .frame(minWidth: 44, minHeight: 44)
                
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                        .foregroundColor(.primaryGreen)
                }
                .frame(minWidth: 44, minHeight: 44)
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                .frame(minWidth: 44, minHeight: 44)
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.surfaceBackground, lineWidth: 1)
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
