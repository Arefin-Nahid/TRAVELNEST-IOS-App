import Foundation

struct Booking: Identifiable, Codable {
    let id: String
    let userId: String
    let hotelId: String
    let hotelName: String
    let checkInDate: Date
    let checkOutDate: Date
    let numberOfGuests: Int
    let totalPrice: Double
    let status: BookingStatus
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case hotelId = "hotel_id"
        case hotelName = "hotel_name"
        case checkInDate = "check_in_date"
        case checkOutDate = "check_out_date"
        case numberOfGuests = "number_of_guests"
        case totalPrice = "total_price"
        case status
        case createdAt = "created_at"
    }
} 
