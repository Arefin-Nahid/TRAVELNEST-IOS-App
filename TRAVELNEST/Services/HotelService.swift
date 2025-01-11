import Foundation
import FirebaseFirestore

class HotelService {
    static let shared = HotelService()
    private let db = Firestore.firestore()
    weak var delegate: HotelDelegate?
    
    // Load local JSON data
    func loadLocalHotels() -> [Hotel] {
        do {
            let response: HotelResponse = try JSONParserService.shared.loadJSON(filename: "hotels")
            return response.hotels
        } catch {
            print("Error loading hotels: \(error)")
            return []
        }
    }
    
    // Fetch hotels from Firestore
    func fetchHotels() async throws -> [Hotel] {
        let snapshot = try await db.collection("hotels").getDocuments()
        let hotels = snapshot.documents.compactMap { document in
            try? document.data(as: Hotel.self)
        }
        return hotels
    }
    
    // Book a hotel
    func bookHotel(_ hotel: Hotel, booking: Booking) async throws {
        try await FirebaseManager.shared.saveBooking(booking)
        delegate?.didBookHotel(hotel, booking: booking)
    }
    
    // Select a hotel
    func selectHotel(_ hotel: Hotel) {
        delegate?.didSelectHotel(hotel)
    }
}

struct HotelResponse: Codable {
    let hotels: [Hotel]
} 