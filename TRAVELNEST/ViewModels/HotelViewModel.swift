import Foundation
import FirebaseFirestore

@MainActor
class HotelViewModel: ObservableObject {
    @Published var featuredHotels: [Hotel] = []
    @Published var popularHotels: [Hotel] = []
    @Published var allHotels: [Hotel] = []
    @Published var selectedHotel: Hotel?
    @Published var lastBooking: Booking?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let hotelService: HotelService
    
    init(hotelService: HotelService = .shared) {
        self.hotelService = hotelService
        loadHotels()
    }
    
    func loadHotels() {
        Task {
            isLoading = true
            
            do {
                let hotels = try await hotelService.fetchHotels()
                
                if hotels.isEmpty {
                    try await FirebaseManager.shared.addSampleHotels()
                    let updatedHotels = try await hotelService.fetchHotels()
                    updateHotels(updatedHotels)
                } else {
                    updateHotels(hotels)
                }
            } catch {
                let localHotels = hotelService.loadLocalHotels()
                updateHotels(localHotels)
                self.errorMessage = error.localizedDescription
            }
            
            self.isLoading = false
        }
    }
    
    func selectHotel(_ hotel: Hotel) {
        selectedHotel = hotel
    }
    
    func bookHotel(_ hotel: Hotel, booking: Booking) {
        lastBooking = booking
    }
    
    private func updateHotels(_ hotels: [Hotel]) {
        self.allHotels = hotels
        self.featuredHotels = hotels.filter { $0.isFeatured }
        self.popularHotels = hotels.filter { $0.isPopular }
    }
}

// Move delegate conformance to an extension
extension HotelViewModel: HotelDelegate {
    nonisolated func didSelectHotel(_ hotel: Hotel) {
        Task { @MainActor in
            self.selectHotel(hotel)
        }
    }
    
    nonisolated func didBookHotel(_ hotel: Hotel, booking: Booking) {
        Task { @MainActor in
            self.bookHotel(hotel, booking: booking)
        }
    }
    
    nonisolated func didUpdateFavorites(_ hotel: Hotel) {
        // Implement if needed
    }
} 