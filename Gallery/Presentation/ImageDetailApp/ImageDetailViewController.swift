import UIKit
import Kingfisher
import Photos


final class ImageDetailViewController: UIViewController {

    private let viewModel: ImageDetailViewModel

    private let titleLabel = UILabel()
    private let infoButton = UIButton(type: .system)
    private let favoriteButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private let editNoteButton = UIButton(type: .system)
    private let downloadButton = UIButton(type: .system)
    
    private let noteMaxLength = 100

    private var layout: UICollectionViewFlowLayout!
    private var collectionView: UICollectionView!

    private let noteLabel = UILabel()

    private var prefetcher: ImagePrefetcher?

    private var heartBarItem: UIBarButtonItem!
    private var menuBarItem: UIBarButtonItem!

    // MARK: - Init
    init(viewModel: ImageDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        buildTopBar()
        buildCollection()
        buildNoteLabel()
        bindViewModel()
        setupNavItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        viewModel.refreshNotes()
        updateTopBarAndNote()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let idx = IndexPath(item: viewModel.currentIndex, section: 0)
        collectionView.scrollToItem(at: idx, at: .centeredHorizontally, animated: false)
        prefetchAround(index: viewModel.currentIndex)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if layout.itemSize != collectionView.bounds.size {
            layout.itemSize = collectionView.bounds.size
            layout.invalidateLayout()
            let idx = IndexPath(item: viewModel.currentIndex, section: 0)
            collectionView.scrollToItem(at: idx, at: .centeredHorizontally, animated: false)
        }
    }

    // MARK: - UI Builders
    private func buildTopBar() {
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        infoButton.tintColor = .white
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
/*
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = .white
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
*/
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.tintColor = .systemPink
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
/*
        editNoteButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        editNoteButton.tintColor = .white
        editNoteButton.addTarget(self, action: #selector(editNoteTapped), for: .touchUpInside)
        editNoteButton.translatesAutoresizingMaskIntoConstraints = false
*/
        view.addSubview(titleLabel)
        view.addSubview(infoButton)
  //      view.addSubview(shareButton)
        view.addSubview(favoriteButton)
//        view.addSubview(editNoteButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            infoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            infoButton.widthAnchor.constraint(equalToConstant: 44),
            infoButton.heightAnchor.constraint(equalToConstant: 44),

            favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            favoriteButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44),
/*
            shareButton.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -10),
            shareButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 44),
            shareButton.heightAnchor.constraint(equalToConstant: 44),

            editNoteButton.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -10),
            editNoteButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            editNoteButton.widthAnchor.constraint(equalToConstant: 44),
            editNoteButton.heightAnchor.constraint(equalToConstant: 44),
 */
        ])
    }

    private func buildCollection() {
        layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = view.bounds.size

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ZoomableImageCell.self, forCellWithReuseIdentifier: ZoomableImageCell.reuseID)

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120)
        ])
        

    }

    private func showSimpleAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    
    private func buildNoteLabel() {
        noteLabel.textColor = .white
        noteLabel.numberOfLines = 0
        noteLabel.font = .systemFont(ofSize: 15)
        noteLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noteLabel)

        NSLayoutConstraint.activate([
            noteLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 12),
            noteLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noteLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            noteLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),

        ])

    }

    private func bindViewModel() {
        viewModel.onImageChanged = { [weak self] _ in
            self?.updateTopBarAndNote()
        }
        viewModel.onFavoriteStatusChanged = { [weak self] isFav in
            self?.updateFavoriteButtonUI(isFavorite: isFav)
        }
        updateTopBarAndNote()
        
    }

    private func setupNavItems() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = viewModel.currentImage.user.name

        
        menuBarItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(showMenu(_:))
        )

        navigationItem.rightBarButtonItems = [menuBarItem]
    }

    private func symbol(_ name: String) -> UIImage? {
        let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .regular, scale: .medium)
        return UIImage(systemName: name, withConfiguration: cfg)
    }

    @objc private func noteTextDidChange(_ tf: UITextField) {
        if let alert = presentedViewController as? UIAlertController {
            let count = (tf.text ?? "").count
            alert.message = "\(count)/\(noteMaxLength)"
        }
    }

    @objc private func favoriteTapped() {
        viewModel.toggleFavoriteStatus()
        heartBarItem.image = UIImage(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
    }

    @objc private func showMenu(_ sender: UIBarButtonItem) {
        let hasNote  = !(viewModel.notes ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let noteText = hasNote ? "Edit Note" : "Add Note"

        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.view.tintColor = .label

        let note  = UIAlertAction(title: noteText, style: .default) { [weak self] _ in self?.presentNoteAlert() }
        let share = UIAlertAction(title: "Share", style: .default) { [weak self] _ in self?.shareCurrent() }

        note.setValue(symbol("square.and.pencil"), forKey: "image")
        share.setValue(symbol("square.and.arrow.up"), forKey: "image")

        [note, share].forEach(sheet.addAction)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        sheet.popoverPresentationController?.barButtonItem = sender
        present(sheet, animated: true)
    }
    
    private func infoAction() {
        let msg = viewModel.currentImage.description ?? "No description available."
        let alert = UIAlertController(title: "Description", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func presentNoteAlert() {
        let current = viewModel.notes ?? ""
        let alert = UIAlertController(
            title: "Note",
            message: "\(current.count)/\(noteMaxLength)",
            preferredStyle: .alert
        )

        alert.addTextField { [weak self] tf in
            guard let self = self else { return }
            tf.placeholder = "Your note"
            tf.text = current
            tf.clearButtonMode = .whileEditing
            tf.delegate = self
            tf.addTarget(self, action: #selector(self.noteTextDidChange(_:)), for: .editingChanged)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let text = alert.textFields?.first?.text ?? ""
            let limited = String(text.prefix(self.noteMaxLength))
            self.viewModel.saveNotes(text: limited)
            self.viewModel.refreshNotes()
            self.updateTopBarAndNote()
        }))

        present(alert, animated: true)
    }

    
    private func shareCurrent() {
        guard let url = URL(string: viewModel.currentImage.urls.regular) else { return }
        KingfisherManager.shared.cache.retrieveImage(forKey: url.absoluteString) { [weak self] result in
            let avc: UIActivityViewController
            switch result {
            case .success(let v) where v.image != nil:
                avc = UIActivityViewController(activityItems: [v.image!], applicationActivities: nil)
            default:
                avc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            }
            avc.popoverPresentationController?.barButtonItem = self?.menuBarItem
            self?.present(avc, animated: true)
        }
    }

    
    private func updateTopBarAndNote() {
        titleLabel.text = viewModel.currentImage.user.name
        updateFavoriteButtonUI(isFavorite: viewModel.isFavorite)
        let text = (viewModel.notes ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        noteLabel.text = text.isEmpty ? " " : text
    }

    private func updateFavoriteButtonUI(isFavorite: Bool) {
        let name = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: name), for: .normal)
    }

    // MARK: - Actions
    @objc private func infoButtonTapped() {
        let message = viewModel.currentImage.description ?? "No description available."
        let alert = UIAlertController(title: "Description", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func favoriteButtonTapped() {
        viewModel.toggleFavoriteStatus()
    }

    @objc private func editNoteTapped() {
        let alert = UIAlertController(title: "Note",
                                      message: "Enter a note for this image",
                                      preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Your note"
            tf.text = self.viewModel.notes
            tf.clearButtonMode = .whileEditing
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let text = alert.textFields?.first?.text
            self.viewModel.saveNotes(text: text)
            self.updateTopBarAndNote()
        }))
        present(alert, animated: true)
    }

    @objc private func shareButtonTapped() {
        guard let url = URL(string: viewModel.currentImage.urls.regular) else { return }
        KingfisherManager.shared.cache.retrieveImage(forKey: url.absoluteString) { [weak self] result in
            switch result {
            case .success(let value) where value.image != nil:
                let avc = UIActivityViewController(activityItems: [value.image!], applicationActivities: nil)
                self?.present(avc, animated: true)
            default:
                let avc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                self?.present(avc, animated: true)
            }
        }
    }

    // MARK: - Paging helpers
    private func currentPage(from scrollView: UIScrollView) -> Int {
        let page = Int(round(scrollView.contentOffset.x / max(scrollView.bounds.width, 1)))
        return max(0, min(page, viewModel.images.count - 1))
    }

    private func syncViewModel(to page: Int) {
        let delta = page - viewModel.currentIndex
        guard delta != 0 else { return }
        if delta > 0 {
            for _ in 0..<delta { viewModel.showNextImage() }
        } else {
            for _ in 0..<(-delta) { viewModel.showPreviousImage() }
        }
        updateTopBarAndNote()
        prefetchAround(index: viewModel.currentIndex)
    }

    private func prefetchAround(index: Int) {
        let candidates = [index - 1, index + 1].filter { $0 >= 0 && $0 < viewModel.images.count }
        let urls = candidates.compactMap { URL(string: viewModel.images[$0].urls.regular) }
        guard !urls.isEmpty else { return }
        prefetcher?.stop()
        prefetcher = ImagePrefetcher(urls: urls)
        prefetcher?.start()
    }
}

extension ImageDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let current = textField.text ?? ""
        guard let r = Range(range, in: current) else { return false }

        let updated = current.replacingCharacters(in: r, with: string)

        if updated.count <= noteMaxLength {
            if let alert = presentedViewController as? UIAlertController {
                alert.message = "\(updated.count)/\(noteMaxLength)"
            }
            return true
        }

        let remaining = noteMaxLength - (current.count - range.length)
        if remaining > 0 {
            let allowed = String(string.prefix(remaining))
            let newText = current.replacingCharacters(in: r, with: allowed)
            textField.text = newText
            if let alert = presentedViewController as? UIAlertController {
                alert.message = "\(noteMaxLength)/\(noteMaxLength)"
            }
        }
        return false
    }
}


// MARK: - Data Source
extension ImageDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZoomableImageCell.reuseID, for: indexPath) as! ZoomableImageCell
        cell.configure(with: viewModel.images[indexPath.item].urls.regular)
        return cell
    }
}

// MARK: - Delegate
extension ImageDetailViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        syncViewModel(to: currentPage(from: scrollView))
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        syncViewModel(to: currentPage(from: scrollView))
    }
}

// MARK: - Prefetching
extension ImageDetailViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap { URL(string: viewModel.images[$0.item].urls.regular) }
        guard !urls.isEmpty else { return }
        prefetcher?.stop()
        prefetcher = ImagePrefetcher(urls: urls)
        prefetcher?.start()
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        prefetcher?.stop()
    }
}



// MARK: - Zoomable cell
final class ZoomableImageCell: UICollectionViewCell, UIScrollViewDelegate {
    static let reuseID = "ZoomableImageCell"

    private let scrollView = UIScrollView()
    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        contentView.backgroundColor = .black

        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            imageView.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        scrollView.setZoomScale(1, animated: false)
    }

    func configure(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        imageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
    }

    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0)
        imageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
                                   y: scrollView.contentSize.height * 0.5 + offsetY)
    }

    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(1, animated: true)
        } else {
            let newScale = min(scrollView.maximumZoomScale, 2)
            let point = gesture.location(in: imageView)
            let width = scrollView.bounds.size.width / newScale
            let height = scrollView.bounds.size.height / newScale
            let rect = CGRect(x: point.x - width/2, y: point.y - height/2, width: width, height: height)
            scrollView.zoom(to: rect, animated: true)
        }
    }
}
