import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)), Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))]),
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Header
                Text("Reset Password")
                    .font(.system(size: 35, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Enter your email to reset your password")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Email Field
                CustomTextField(text: $email,
                             placeholder: "Email",
                             iconName: "envelope.fill")
                    .padding(.horizontal)
                
                // Reset Button
                Button(action: {
                    Task {
                        await authViewModel.resetPassword(email: email)
                        showAlert = true
                    }
                }) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    } else {
                        Text("Send Reset Link")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.white)
                .cornerRadius(15)
                .padding(.horizontal)
                .disabled(email.isEmpty || authViewModel.isLoading)
                
                // Error/Success Message
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .foregroundColor(.white)
                        .padding()
                        .multilineTextAlignment(.center)
                }
                
                // Back to Login
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back to Login")
                    }
                    .foregroundColor(.white)
                }
                .padding(.top)
            }
            .padding()
        }
        .alert("Password Reset", isPresented: $showAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("If an account exists with this email, you will receive a password reset link.")
        }
    }
} 