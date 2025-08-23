
import Foundation

struct Image: Codable, Equatable {
    let id: String
    let urls: ImageUrls
    let user: User
    let description: String?
   
}


struct ImageUrls: Codable, Equatable {
    let raw, full, regular, small, thumb: String
}

struct User: Codable, Equatable {
    let name: String
    let username: String
}
