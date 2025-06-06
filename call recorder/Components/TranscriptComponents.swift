import SwiftUI

struct TranscriptEmptyState: View {
    let userType: AppViewModel.UserType
    let onUpgrade: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 80))
                .foregroundColor(.darkGrey)
            
            VStack(spacing: 8) {
                Text("No Transcripts Available")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.navyBlue)
                
                if userType == .free {
                    Text("Upgrade to Premium to unlock transcripts for all your recordings")
                        .font(.subheadline)
                        .foregroundColor(.darkGrey)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: onUpgrade) {
                        HStack {
                            Image(systemName: "crown.fill")
                            Text("Upgrade to Premium")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.skyBlue)
                        .cornerRadius(12)
                    }
                    .frame(minHeight: 44)
                    .padding(.top)
                } else {
                    Text("Record calls to see transcripts here")
                        .font(.subheadline)
                        .foregroundColor(.darkGrey)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.lightGrey)
    }
}

struct TranscriptLoadingView: View {
    @State private var dots = ""
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.skyBlue)
            
            Text("Generating transcript\(dots)")
                .font(.subheadline)
                .foregroundColor(.navyBlue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            withAnimation {
                if dots.count < 3 {
                    dots += "."
                } else {
                    dots = ""
                }
            }
        }
    }
}

#Preview {
    TranscriptEmptyState(userType: .free) {}
}