import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            LoginView()
        } else {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [
                    Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)),
                    Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))
                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                VStack {
                    VStack(spacing: 20) {
                        // App Icon
                        Image(systemName: "airplane.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(isActive ? 360 : 0))
                            .animation(.easeInOut(duration: 1), value: isActive)
                        
                        // App Name with animated text
                        Text("TRAVEL NEST")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(4)
                        
                        // Tagline
                        Text("Your Journey Begins Here")
                            .font(.system(size: 18, weight: .light, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.size = 0.9
                            self.opacity = 1.0
                        }
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
} 