import SwiftUI

struct DataUsageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var totalRecordings = 47
    @State private var totalStorage = "2.3 GB"
    @State private var monthlyUploads = "156 MB"
    @State private var averageCallLength = "4:32"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Data Usage")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryText)
                        
                        Text("Monitor your app's data consumption and storage usage")
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                    }
                    
                    // Storage Overview
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Storage Overview", icon: "internaldrive")
                        
                        VStack(spacing: 12) {
                            DataRow(
                                icon: "waveform",
                                title: "Total Recordings",
                                value: "\(totalRecordings)",
                                color: .primaryGreen
                            )
                            
                            DataRow(
                                icon: "externaldrive",
                                title: "Storage Used",
                                value: totalStorage,
                                color: .blue
                            )
                            
                            DataRow(
                                icon: "clock",
                                title: "Average Call Length",
                                value: averageCallLength,
                                color: .orange
                            )
                        }
                    }
                    
                    // Network Usage
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Network Usage", icon: "wifi")
                        
                        VStack(spacing: 12) {
                            DataRow(
                                icon: "icloud.and.arrow.up",
                                title: "Monthly Uploads",
                                value: monthlyUploads,
                                color: .purple
                            )
                            
                            DataRow(
                                icon: "icloud.and.arrow.down",
                                title: "Monthly Downloads",
                                value: "23 MB",
                                color: .cyan
                            )
                            
                            DataRow(
                                icon: "antenna.radiowaves.left.and.right",
                                title: "Sync Status",
                                value: "Up to date",
                                color: .green
                            )
                        }
                    }
                    
                    // Data Management
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Data Management", icon: "gearshape")
                        
                        VStack(spacing: 0) {
                            DataManagementRow(
                                icon: "trash",
                                title: "Clear Cache",
                                subtitle: "Remove temporary files",
                                action: {
                                    // Handle cache clearing
                                }
                            )
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            DataManagementRow(
                                icon: "icloud.slash",
                                title: "Offline Mode",
                                subtitle: "Reduce data usage",
                                action: {
                                    // Handle offline mode toggle
                                }
                            )
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            DataManagementRow(
                                icon: "arrow.down.circle",
                                title: "Download Quality",
                                subtitle: "Standard quality",
                                action: {
                                    // Handle quality settings
                                }
                            )
                        }
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.surfaceBackground, lineWidth: 1)
                        )
                    }
                }
                .padding()
            }
            .background(Color.darkBackground)
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryGreen)
                }
            }
        }
    }
}

struct DataRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primaryText)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primaryText)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.surfaceBackground, lineWidth: 1)
        )
    }
}

struct DataManagementRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(.primaryGreen)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.primaryText)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.tertiaryText)
                    .font(.caption)
            }
            .padding()
        }
    }
}

#Preview {
    DataUsageView()
}