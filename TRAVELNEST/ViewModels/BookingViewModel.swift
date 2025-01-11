import Foundation
import FirebaseAuth

@MainActor
class BookingViewModel: ObservableObject {
    @Published var userBookings: [Booking] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    init() {
        Task {
            await loadUserBookings()
        }
    }
    
    func loadUserBookings() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        do {
            let bookings = try await FirebaseManager.shared.fetchUserBookings(userId: userId)
            self.userBookings = bookings.sorted { $0.createdAt > $1.createdAt }
        } catch {
            print("Error loading bookings: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
        }
        
        self.isLoading = false
    }
} 