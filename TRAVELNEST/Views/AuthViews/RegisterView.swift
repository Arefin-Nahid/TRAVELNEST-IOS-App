import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSecured = true
    @State private var isConfirmSecured = true
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)), Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))]),
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 15) {
                        Text("Create Account")
                            .font(.system(size: 35, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Sign up to get started!")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 40)
                    
                    // Registration Form
                    VStack(spacing: 20) {
                        // Full Name Field
                        CustomTextField(text: $fullName,
                                     placeholder: "Full Name",
                                     iconName: "person.fill")
                        
                        // Email Field
                        CustomTextField(text: $email,
                                     placeholder: "Email",
                                     iconName: "envelope.fill")
                        
                        // Password Field
                        CustomSecureField(password: $password,
                                        isSecured: $isSecured,
                                        placeholder: "Password")
                        
                        // Confirm Password Field
                        CustomSecureField(password: $confirmPassword,
                                        isSecured: $isConfirmSecured,
                                        placeholder: "Confirm Password")
                        
                        // Register Button
                        Button(action: {
                            authViewModel.register(email: email, password: password, fullName: fullName)
                        }) {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            } else {
                                Text("Register")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .disabled(authViewModel.isLoading)
                        
                        // Add error message display
                        if !authViewModel.errorMessage.isEmpty {
                            Text(authViewModel.errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        // Login Link
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Text("Already have an account?")
                                    .foregroundColor(.white.opacity(0.8))
                                Text("Login")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                }
            }
        }
    }
} 