import UIKit
import Kingfisher

// MARK: - FavoritesViewController
class FavoriteImageViewController: UIViewController {
    private var viewModel: FavoriteImageViewModel!
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorites"
        setupViewModel()
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadFavorites()
    }
    
    private func setupViewModel() {
        let repository = ImageRepository()
        self.viewModel = FavoriteImageViewModel(repository: repository)
        
        viewModel.onFavoritesLoaded = { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        let itemWidth = (view.frame.width / 3) - 1
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(GalleryImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension FavoriteImageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.favoriteImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? GalleryImageCell else {
            return UICollectionViewCell()
        }
        let image = viewModel.favoriteImages[indexPath.row]
        cell.configure(with: image.urls.thumb)
        return cell
    }
}

extension FavoriteImageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let toggleFavoriteUseCase = ToggleFavoriteUseCase(repository: ImageRepository())
            let detailViewModel = ImageDetailViewModel(
                images: viewModel.favoriteImages,
                currentIndex: indexPath.row,
                toggleFavoriteUseCase: toggleFavoriteUseCase
            )
            let detailVC = ImageDetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailVC, animated: true)
        }
}
