import Foundation
import FirebaseAuth
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    init() {
        self.userSession = Auth.auth().currentUser
        self.isAuthenticated = userSession != nil
        
        if let userId = userSession?.uid {
            Task {
                await fetchUser(userId: userId)
            }
        }
    }
    
    func login(email: String, password: String) {
        isLoading = true
        
        Task {
            do {
                let result = try await FirebaseManager.shared.loginUser(email: email, password: password)
                await fetchUser(userId: result.user.uid)
                
                await MainActor.run {
                    self.userSession = result.user
                    self.isAuthenticated = true
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func register(email: String, password: String, fullName: String) {
        isLoading = true
        
        Task {
            do {
                let result = try await FirebaseManager.shared.registerUser(email: email, password: password, fullName: fullName)
                await fetchUser(userId: result.user.uid)
                
                await MainActor.run {
                    self.userSession = result.user
                    self.isAuthenticated = true
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func signOut() {
        do {
            try FirebaseManager.shared.signOut()
            self.userSession = nil
            self.currentUser = nil
            self.isAuthenticated = false
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    private func fetchUser(userId: String) async {
        do {
            let user = try await FirebaseManager.shared.fetchUserData(userId: userId)
            self.currentUser = user
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = ""
        
        do {
            try await FirebaseManager.shared.resetPassword(email: email)
            self.errorMessage = "Password reset email sent. Please check your inbox."
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
} 