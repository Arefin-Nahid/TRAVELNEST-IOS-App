import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private let db = Firestore.firestore()
    
    // Login with email and password
    func loginUser(email: String, password: String) async throws -> AuthDataResult {
        return try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    // Register new user
    func registerUser(email: String, password: String, fullName: String) async throws -> AuthDataResult {
        // Create authentication user
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
        // Update display name
        let changeRequest = authResult.user.createProfileChangeRequest()
        changeRequest.displayName = fullName
        try await changeRequest.commitChanges()
        
        // Create user document in Firestore
        let user = User(
            id: authResult.user.uid,
            fullName: fullName,
            email: email,
            createdAt: Date()
        )
        
        try await storeUserData(user)
        
        return authResult
    }
    
    // Store user data in Firestore
    private func storeUserData(_ user: User) async throws {
        let userData: [String: Any] = [
            "full_name": user.fullName,
            "email": user.email,
            "created_at": Timestamp(date: user.createdAt)
        ]
        
        try await db.collection("users").document(user.id).setData(userData)
    }
    
    // Fetch user data
    func fetchUserData(userId: String) async throws -> User {
        let document = try await db.collection("users").document(userId).getDocument()
        
        guard let data = document.data(),
              let fullName = data["full_name"] as? String,
              let email = data["email"] as? String,
              let createdAt = (data["created_at"] as? Timestamp)?.dateValue() else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid user data"])
        }
        
        return User(
            id: userId,
            fullName: fullName,
            email: email,
            createdAt: createdAt
        )
    }
    
    // Sign out
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // Check if user is logged in
    var isUserLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    // Add sample hotels to Firestore
    func addSampleHotels() async throws {
        let hotels = [
            [
                "id": "1",
                "name": "Luxury Hotel & Spa",
                "description": "Experience luxury at its finest with our world-class amenities and services.",
                "location": "Cox's Bazar, Bangladesh",
                "price": 199.99,
                "rating": 4.8,
                "reviews": 220,
                "images": ["hotel1_1", "hotel1_2", "hotel1_3"],
                "amenities": ["WiFi", "Pool", "Spa", "Restaurant", "Gym"],
                "category": "Luxury",
                "is_popular": true,
                "is_featured": true
            ],
            [
                "id": "2",
                "name": "Business Center Hotel",
                "description": "Perfect for business travelers with modern facilities.",
                "location": "Dhaka, Bangladesh",
                "price": 149.99,
                "rating": 4.5,
                "reviews": 180,
                "images": ["hotel2_1", "hotel2_2", "hotel2_3"],
                "amenities": ["WiFi", "Business Center", "Restaurant", "Gym"],
                "category": "Business",
                "is_popular": true,
                "is_featured": true
            ],
            [
                "id": "3",
                "name": "Sea Pearl Beach Resort",
                "description": "Luxury beachfront resort with stunning ocean views.",
                "location": "Cox's Bazar, Bangladesh",
                "price": 299.99,
                "rating": 4.9,
                "reviews": 350,
                "images": ["hotel3_1", "hotel3_2", "hotel3_3"],
                "amenities": ["Beach Access", "Pool", "Spa", "Restaurant", "Bar"],
                "category": "Resort",
                "is_popular": true,
                "is_featured": true
            ],
            [
                "id": "4",
                "name": "Royal Palace Hotel",
                "description": "Experience royal treatment in the heart of the city.",
                "location": "Dhaka, Bangladesh",
                "price": 259.99,
                "rating": 4.7,
                "reviews": 280,
                "images": ["hotel4_1", "hotel4_2", "hotel4_3"],
                "amenities": ["WiFi", "Pool", "Spa", "Restaurant", "Gym"],
                "category": "Luxury",
                "is_popular": true,
                "is_featured": true
            ],
            [
                "id": "5",
                "name": "Mountain View Resort",
                "description": "Peaceful retreat with breathtaking mountain views.",
                "location": "Bandarban, Bangladesh",
                "price": 179.99,
                "rating": 4.6,
                "reviews": 190,
                "images": ["hotel5_1", "hotel5_2", "hotel5_3"],
                "amenities": ["Mountain View", "Restaurant", "Hiking", "Spa"],
                "category": "Resort",
                "is_popular": false,
                "is_featured": true
            ]
        ]
        
        for hotel in hotels {
            try await db.collection("hotels").document(hotel["id"] as! String).setData(hotel)
        }
    }
    
    func saveBooking(_ booking: Booking) async throws {
        let bookingData: [String: Any] = [
            "user_id": booking.userId,
            "hotel_id": booking.hotelId,
            "hotel_name": booking.hotelName,
            "check_in_date": Timestamp(date: booking.checkInDate),
            "check_out_date": Timestamp(date: booking.checkOutDate),
            "number_of_guests": booking.numberOfGuests,
            "total_price": booking.totalPrice,
            "status": booking.status.rawValue,
            "created_at": Timestamp(date: booking.createdAt)
        ]
        
        do {
            try await db.collection("bookings").document(booking.id).setData(bookingData)
            print("Booking saved successfully with ID: \(booking.id)")
        } catch {
            print("Error saving booking: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchUserBookings(userId: String) async throws -> [Booking] {
        print("Fetching bookings for user: \(userId)")
        
        let snapshot = try await db.collection("bookings")
            .whereField("user_id", isEqualTo: userId)
            .getDocuments()
        
        let bookings = try snapshot.documents.map { document in
            let data = document.data()
            return Booking(
                id: document.documentID,
                userId: data["user_id"] as! String,
                hotelId: data["hotel_id"] as! String,
                hotelName: data["hotel_name"] as! String,
                checkInDate: (data["check_in_date"] as! Timestamp).dateValue(),
                checkOutDate: (data["check_out_date"] as! Timestamp).dateValue(),
                numberOfGuests: data["number_of_guests"] as! Int,
                totalPrice: data["total_price"] as! Double,
                status: BookingStatus(rawValue: data["status"] as! String) ?? .pending,
                createdAt: (data["created_at"] as! Timestamp).dateValue()
            )
        }
        
        print("Found \(bookings.count) bookings")
        return bookings
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("Password reset email sent to: \(email)")
        } catch {
            print("Error sending password reset: \(error.localizedDescription)")
            throw error
        }
    }
} 