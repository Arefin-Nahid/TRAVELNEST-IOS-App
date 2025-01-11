import Foundation

protocol HotelDelegate: AnyObject {
    func didSelectHotel(_ hotel: Hotel)
    func didBookHotel(_ hotel: Hotel, booking: Booking)
    func didUpdateFavorites(_ hotel: Hotel)
}

// Optional implementations
extension HotelDelegate {
    func didSelectHotel(_ hotel: Hotel) {}
    func didBookHotel(_ hotel: Hotel, booking: Booking) {}
    func didUpdateFavorites(_ hotel: Hotel) {}
} 