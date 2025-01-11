import Foundation

enum JSONParserError: Error {
    case fileNotFound
    case decodingError(Error)
}

class JSONParserService {
    static let shared = JSONParserService()
    
    private init() {}
    
    func loadJSON<T: Decodable>(filename: String) throws -> T {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw JSONParserError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw JSONParserError.decodingError(error)
        }
    }
    
    func parseJSON<T: Decodable>(_ data: Data) throws -> T {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw JSONParserError.decodingError(error)
        }
    }
} 