import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel = AppViewModel.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Binding var navigationPath: NavigationPath
    
    @State private var searchText = ""
    @State private var selectedFilter = 0 // Index of selected filter
    @State private var selectedRecording: Recording?
    @State private var showPlayer = false
    @State private var showDeleteAlert = false
    @State private var recordingToDelete: Recording?
    @State private var showShareSheet = false
    @State private var recordingToShare: Recording?
    
    var filters: [String] {
        [localizationManager.localizedString("all"),
         localizationManager.localizedString("today"),
         localizationManager.localizedString("week")]
    }
    
    var filteredRecordings: [Recording] {
        let filterTypes = ["All", "Today", "Week"]
        return viewModel.filterRecordings(by: filterTypes[selectedFilter], searchText: searchText)
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
                                        navigationPath.append(NavigationDestination.player(recording))
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
                                .onTapGesture {
                                    HapticManager.shared.impact(.light)
                                    navigationPath.append(NavigationDestination.callDetails(recording))
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    .refreshable {
                        await viewModel.fetchCallsFromServerAsync()
                    }
                }
            }
            .navigationTitle(localized("recordings"))
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .background(Color.darkBackground)
        }
        .sheet(isPresented: $showShareSheet) {
            if let recording = recordingToShare {
                ShareSheet(items: [recording])
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
    }
}


struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondaryText)
            
            TextField(localized("search_recordings"), text: $text)
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
    @Binding var selectedFilter: Int
    let filters: [String]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<filters.count, id: \.self) { index in
                FilterButton(
                    title: filters[index],
                    isSelected: selectedFilter == index,
                    action: { selectedFilter = index }
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
        HStack(spacing: 16) {
            Image(systemName: "phone.fill")
                .foregroundColor(.primaryGreen)
                .font(.system(size: 20))
                .frame(width: 44, height: 44)
                .background(Color.primaryGreen.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recording.contactName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primaryText)
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    Text(formatTime(recording.date))
                        .font(.system(size: 13))
                        .foregroundColor(.secondaryText)
                    
                    Text(formatDuration(recording.duration))
                        .font(.system(size: 13))
                        .foregroundColor(.primaryGreen)
                }
            }
            
            Spacer()
            
            Menu {
                Button(action: onPlay) {
                    Label(localized("play"), systemImage: "play.fill")
                }
                Button(action: onShare) {
                    Label(localized("share"), systemImage: "square.and.arrow.up")
                }
                Button(role: .destructive, action: onDelete) {
                    Label(localized("delete"), systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16))
                    .foregroundColor(.secondaryText)
                    .frame(width: 32, height: 32)
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
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func formatSimpleDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
