
import Foundation

// MARK: - ToggleFavoriteUseCase
class ToggleFavoriteUseCase {
    private let repository: ImageRepositoryProtocol

    init(repository: ImageRepositoryProtocol) {
        self.repository = repository
    }

    func execute(image: Image) -> Bool {
        let isCurrentlyFavorite = repository.isFavorite(image: image)
            
        if isCurrentlyFavorite {
            repository.removeFavorite(image: image)
        } else {
            repository.saveFavorite(image: image, notes: nil)
        }

        return !isCurrentlyFavorite
    }
        
    func isFavorite(image: Image) -> Bool {
        return repository.isFavorite(image: image)
    }

    func getFavorite(imageId: String) -> FavoriteImage? {
        repository.getFavorite(imageId: imageId)
    }
    
    func updateNotes(imageId: String, notes: String?) {
        repository.updateNotes(imageId: imageId, notes: notes)
    }
}
