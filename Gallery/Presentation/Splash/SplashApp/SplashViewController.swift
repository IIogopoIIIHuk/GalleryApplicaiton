import UIKit

final class SplashViewController: UIViewController {

    private let logoImageView = UIImageView(image: UIImage(named: "SplashImage"))
    private let titleLabel = UILabel()

    var onFinish: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        
        titleLabel.text = "GalleryApp"
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.alpha = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(logoImageView)
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -16),
            logoImageView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.45),
            logoImageView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.45),

            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runAnimation()
    }

    private func runAnimation() {
        logoImageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85).rotated(by: -0.12)
        logoImageView.alpha = 0


        UIView.animate(withDuration: 1.25,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.8,
                       options: [.curveEaseOut],
                       animations: {
            self.logoImageView.alpha = 1
            self.logoImageView.transform = .identity
        }, completion: { _ in
            UIView.animate(withDuration: 0.35, animations: {
                self.titleLabel.alpha = 1
            }, completion: { _ in
                self.finish()
            })
        })
    }

    private func finish() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.onFinish?()
        }   
    }
}
