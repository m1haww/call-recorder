import SwiftUI

struct ToastView: View {
    let message: String
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                        .shadow(radius: 4)
                    
                    Spacer()
                }
                .padding(.bottom, 100)
            }
            .animation(.easeInOut(duration: 0.3), value: isShowing)
            .transition(.opacity)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isShowing = false
                    }
                }
            }
        }
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    
    func body(content: Content) -> some View {
        ZStack {
            content
            ToastView(message: message, isShowing: $isShowing)
        }
    }
}

extension View {
    func toast(message: String, isShowing: Binding<Bool>) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, message: message))
    }
}