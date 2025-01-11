import Foundation

enum BookingStatus: String, Codable {
    case pending
    case confirmed
    case completed
    case cancelled
} 