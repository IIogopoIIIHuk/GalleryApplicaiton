import Foundation


class GalleryViewModel {
    private let fetchImagesUseCase: FetchImagesUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    
    var onImagesLoaded: (([Image]) -> Void)?
    var onError: ((String) -> Void)?

    private var currentPage = 1
    var images = [Image]()

    init(fetchImagesUseCase: FetchImagesUseCase, toggleFavoriteUseCase: ToggleFavoriteUseCase) {
        self.fetchImagesUseCase = fetchImagesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
    }

    func loadImages() {
        fetchImagesUseCase.execute(page: currentPage) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let newImages):
                self.images.append(contentsOf: newImages)
                self.onImagesLoaded?(self.images)
                self.currentPage += 1
            case .failure(let error):
                self.onError?(error.localizedDescription)
            }
        }
    }
    
    func didSelectImage(at index: Int) -> ImageDetailViewModel? {
        guard index < images.count else { return nil }
        let repository = ImageRepository()
        let toggleFavoriteUseCase = ToggleFavoriteUseCase(repository: repository)
        
        return ImageDetailViewModel(
            images: self.images,
            currentIndex: index,
            toggleFavoriteUseCase: toggleFavoriteUseCase
        )
    }
}
