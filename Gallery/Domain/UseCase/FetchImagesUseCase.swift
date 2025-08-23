import Foundation

class FetchImagesUseCase {
    private let repository: ImageRepositoryProtocol

    init(repository: ImageRepositoryProtocol) {
        self.repository = repository
    }

    func execute(page: Int, completion: @escaping (Result<[Image], Error>) -> Void) {
        repository.fetchImages(page: page, completion: completion)
    }
}
