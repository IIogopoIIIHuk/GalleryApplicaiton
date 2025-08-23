import Foundation

// MARK: - FavoritesViewModel
class FavoriteImageViewModel {
    private let repository: ImageRepositoryProtocol
    var onFavoritesLoaded: (([Image]) -> Void)?

    private(set) var favoriteImages = [Image]()

    init(repository: ImageRepositoryProtocol) {
        self.repository = repository
        loadFavorites()
    }

    func loadFavorites() {
        favoriteImages = repository.fetchFavorites()
        onFavoritesLoaded?(favoriteImages)
    }

    func didSelectImage(at index: Int) -> ImageDetailViewModel? {
        guard index < favoriteImages.count else { return nil }
        let repository = ImageRepository()
        let toggleFavoriteUseCase = ToggleFavoriteUseCase(repository: repository)
        
        return ImageDetailViewModel(
            images: self.favoriteImages,
            currentIndex: index,
            toggleFavoriteUseCase: toggleFavoriteUseCase
        )
    }
}
