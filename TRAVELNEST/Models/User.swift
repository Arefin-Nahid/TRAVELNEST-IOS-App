import Foundation

struct User: Codable {
    let id: String
    let fullName: String
    let email: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case email
        case createdAt = "created_at"
    }
} 