
import Foundation
import Alamofire

class UnsplashAPI {
    private let accessKey = "CZVOGUENbtXFJpUF5m-WO6ggeF9Kj-kcO7jjkuib-uY"
    private let baseUrl = "https://api.unsplash.com"

    func fetchPhotos(page: Int, perPage: Int = 30, completion: @escaping (Result<[Image], Error>) -> Void) {
        let url = baseUrl + "/photos"
        let parameters: [String: Any] = [
            "page": page,
            "per_page": perPage,
            "client_id": accessKey
        ]

        AF.request(url, parameters: parameters).responseDecodable(of: [Image].self) { response in
            switch response.result {
            case .success(let images):
                completion(.success(images))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
