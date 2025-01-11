import Foundation

struct Hotel: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let location: String
    let price: Double
    let rating: Double
    let reviews: Int
    let images: [String]
    let amenities: [String]
    let category: String
    let isPopular: Bool
    let isFeatured: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case location
        case price
        case rating
        case reviews
        case images
        case amenities
        case category
        case isPopular = "is_popular"
        case isFeatured = "is_featured"
    }
} 