import SwiftUI

struct LoginView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var showRegistration = false
    @State private var isSecured = true
    @State private var showForgotPassword = false
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                HomePage()
                    .environmentObject(authViewModel)
            } else {
                ZStack {
                    // Background gradient
                    LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)), Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))]),
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            // Logo and Welcome Text
                            VStack(spacing: 20) {
                                Image(systemName: "airplane.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.white)
                                
                                Text("Welcome Back!")
                                    .font(.system(size: 35, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Sign in to continue")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.top, 40)
                            
                            // Login Form
                            VStack(spacing: 20) {
                                // Email Field
                                CustomTextField(text: $email,
                                             placeholder: "Email",
                                             iconName: "envelope.fill")
                                
                                // Password Field
                                CustomSecureField(password: $password,
                                                isSecured: $isSecured,
                                                placeholder: "Password")
                                
                                // Forgot Password
                                Button(action: {
                                    showForgotPassword = true
                                }) {
                                    Text("Forgot Password?")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16))
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                
                                // Login Button
                                Button(action: {
                                    authViewModel.login(email: email, password: password)
                                }) {
                                    if authViewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                    } else {
                                        Text("Login")
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
                                
                                // Register Link
                                Button(action: {
                                    showRegistration.toggle()
                                }) {
                                    HStack {
                                        Text("Don't have an account?")
                                            .foregroundColor(.white.opacity(0.8))
                                        Text("Register")
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                            .padding(.horizontal, 25)
                        }
                    }
                }
                .sheet(isPresented: $showRegistration) {
                    RegisterView()
                        .environmentObject(authViewModel)
                }
                .sheet(isPresented: $showForgotPassword) {
                    ForgotPasswordView()
                        .environmentObject(authViewModel)
                }
            }
        }
    }
} 