import Foundation

final class ImageDetailViewModel {
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private(set) var images: [Image]
    private(set) var currentIndex: Int
    var notes: String?

    var currentImage: Image { images[currentIndex] }
    var isFavorite: Bool { toggleFavoriteUseCase.isFavorite(image: currentImage) }

    var onFavoriteStatusChanged: ((Bool) -> Void)?
    var onImageChanged: ((Image) -> Void)?

    init(images: [Image], currentIndex: Int, toggleFavoriteUseCase: ToggleFavoriteUseCase) {
        self.images = images
        self.currentIndex = currentIndex
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        refreshNotes()
    }

    func saveNotes(text: String?) {
        if !toggleFavoriteUseCase.isFavorite(image: currentImage) {
            _ = toggleFavoriteUseCase.execute(image: currentImage)
        }
        toggleFavoriteUseCase.updateNotes(imageId: currentImage.id, notes: text)
        notes = text
    }

    func refreshNotes() {
        notes = toggleFavoriteUseCase.getFavorite(imageId: currentImage.id)?.notes
    }

    func toggleFavoriteStatus() {
        let newStatus = toggleFavoriteUseCase.execute(image: currentImage)
        onFavoriteStatusChanged?(newStatus)
    }

    func showNextImage() {
        guard currentIndex < images.count - 1 else { return }
        currentIndex += 1
        refreshNotes()
        onImageChanged?(currentImage)
    }

    func showPreviousImage() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        refreshNotes()
        onImageChanged?(currentImage)
    }

    func setCurrentIndex(_ index: Int) {
        guard index >= 0, index < images.count else { return }
        currentIndex = index
        refreshNotes()
        onImageChanged?(currentImage)
    }
}
