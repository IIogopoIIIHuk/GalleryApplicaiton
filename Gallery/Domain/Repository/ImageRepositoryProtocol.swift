
import Foundation

protocol ImageRepositoryProtocol {
    func fetchImages(page: Int, completion: @escaping (Result<[Image], Error>) -> Void)
    func saveFavorite(image: Image, notes: String?)
    func removeFavorite(image: Image)
    func isFavorite(image: Image) -> Bool
    func fetchFavorites() -> [Image]
    func getFavorite(imageId: String) -> FavoriteImage?
    func updateNotes(imageId: String, notes: String?)

}


