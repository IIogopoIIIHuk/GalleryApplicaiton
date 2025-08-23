import UIKit
import Kingfisher

class GalleryViewController: UIViewController {
    private var viewModel: GalleryViewModel!
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupCollectionView()
        viewModel.loadImages()
    }
    
    private func setupViewModel() {
        let repository = ImageRepository()
        let fetchImagesUseCase = FetchImagesUseCase(repository: repository)
        let toggleFavoriteUseCase = ToggleFavoriteUseCase(repository: repository)
        self.viewModel = GalleryViewModel(fetchImagesUseCase: fetchImagesUseCase, toggleFavoriteUseCase: toggleFavoriteUseCase)
        
        viewModel.onImagesLoaded = { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        viewModel.onError = { error in
            print("Error: \(error)")
        }
    }
    
    private func setupCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        let itemWidth = (view.frame.width / 3) - 1
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear 
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

// MARK: - UICollectionViewDataSource
extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? GalleryImageCell else {
            return UICollectionViewCell()
        }
        let image = viewModel.images[indexPath.row]
        cell.configure(with: image.urls.thumb)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension GalleryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let toggleFavoriteUseCase = ToggleFavoriteUseCase(repository: ImageRepository())
            let detailViewModel = ImageDetailViewModel(
                images: viewModel.images,
                currentIndex: indexPath.row,
                toggleFavoriteUseCase: toggleFavoriteUseCase
            )
            let detailVC = ImageDetailViewController(viewModel: detailViewModel)
            
            navigationController?.pushViewController(detailVC, animated: true)
        }

    
    // MARK: - Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100 {
            viewModel.loadImages()
        }
    }
    
}
