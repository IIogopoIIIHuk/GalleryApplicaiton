
import Foundation
import RealmSwift

class ImageRepository: ImageRepositoryProtocol {
    private let api = UnsplashAPI()
    private let realmManager = RealmManager()

    func fetchImages(page: Int, completion: @escaping (Result<[Image], Error>) -> Void) {
        api.fetchPhotos(page: page, completion: completion)
    }

    func saveFavorite(image: Image, notes: String? = nil) {
        let favoriteImage = FavoriteImage()
        favoriteImage.id = image.id
        favoriteImage.regularUrl = image.urls.regular
        favoriteImage.thumbUrl = image.urls.thumb
        favoriteImage.authorName = image.user.name
        favoriteImage.notes = notes
        realmManager.save(favoriteImage)
    }
    
    func getFavorite(imageId: String) -> FavoriteImage? {
        realmManager.getFavorite(imageId: imageId)
    }

    func updateNotes(imageId: String, notes: String?) {
        realmManager.updateNotes(favoriteImageId: imageId, notes: notes)
    }

    func removeFavorite(image: Image) {
        realmManager.delete(favoriteImageId: image.id)
    }

    func isFavorite(image: Image) -> Bool {
        return realmManager.isFavorite(favoriteImageId: image.id)
    }

    
    func fetchFavorites() -> [Image] {
            let favoriteObjects = realmManager.getFavorites()
            let images = favoriteObjects.map { favorite -> Image in
                let user = User(name: favorite.authorName, username: "")
                let urls = ImageUrls(
                    raw: "",
                    full: "",
                    regular: favorite.regularUrl,
                    small: favorite.thumbUrl,
                    thumb: favorite.thumbUrl
                )
                return Image(id: favorite.id, urls: urls, user: user, description: nil)
            }
            return images
        }
    
}
