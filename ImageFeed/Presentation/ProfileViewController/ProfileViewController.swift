//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 29.12.2022.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let profileService = ProfileDescriptionService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private var animationViews = Set<UIView>()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var exitButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ipad.and.arrow.forward") ?? UIImage(), for: .normal)
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        
        layoutProfileStackView()
        layoutExitButton()
        setupExitButton()
        
        showLoadingAnimation()
        
        updateProfileDetails(profile: profileService.profile)
        
        addNotificationObserver()
        updateAvatar()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

//MARK: - Animation methods
private extension ProfileViewController {
    
    func showLoadingAnimation() {
        let profileGradientView = LoadingGradientAnimationView(
            frame: CGRect(origin: .zero, size: CGSize(width: 70, height: 70)),
            cornerRadius: 35)
        let nameGradientView = LoadingGradientAnimationView(
            frame: CGRect(origin: .zero, size: CGSize(width: 228, height: 28)),
            cornerRadius: 10)
        let loginGradientView = LoadingGradientAnimationView(
            frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 16)),
            cornerRadius: 6)
        
        let gradientViews = [profileGradientView, nameGradientView, loginGradientView]
        addGradientsToSet(gradients: gradientViews)
        addToProfileViews(gradients: gradientViews)
    }
    
    func hideLoadingAnimation() {
        animationViews.forEach { view in
            UIView.animate(withDuration: 0.5, animations: {
                view.alpha = 0
            }) { _ in
                view.removeFromSuperview()
            }
        }
        animationViews.removeAll()
    }
    
    func addGradientsToSet(gradients: [LoadingGradientAnimationView]) {
        gradients.forEach { loadingView in animationViews.insert(loadingView) }
    }
    
    func addToProfileViews(gradients: [LoadingGradientAnimationView]) {
        profileImageView.addSubview(gradients[0])
        nameLabel.addSubview(gradients[1])
        loginNameLabel.addSubview(gradients[2])
    }
}

//MARK: - NotificationCenter methods
private extension ProfileViewController {

    func updateAvatar() {
        guard
            let profileImageURL = profileImageService.profileImageURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        profileImageView.kf.setImage(with: url)
        hideLoadingAnimation()
    }
    
    func addNotificationObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateAvatar()
            }
    }
}

//MARK: - Layout methods
private extension ProfileViewController {
    
    func updateProfileDetails(profile: Profile?) {
        guard let profile = profile else { return }
        loginNameLabel.text = profile.loginName
        nameLabel.text = profile.name
    }
    
    func layoutProfileStackView() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(profileImageView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(loginNameLabel)
        stackView.addArrangedSubview(descriptionLabel)
        
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        stackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 235).isActive = true
        
        layoutProfileImageView()
    }
    
    func layoutProfileImageView() {
        let widthAndHeight: CGFloat = 70
        
        let constraints = [
            profileImageView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: widthAndHeight),
            profileImageView.heightAnchor.constraint(equalToConstant: widthAndHeight),
        ]
        NSLayoutConstraint.activate(constraints)
        profileImageView.layer.cornerRadius = widthAndHeight / 2
    }
    
    func layoutExitButton() {
        view.addSubview(exitButton)
        exitButton.contentHorizontalAlignment = .fill
        exitButton.contentVerticalAlignment = .fill
        
        let constraints = [
            exitButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            exitButton.widthAnchor.constraint(equalToConstant: 24),
            exitButton.heightAnchor.constraint(equalToConstant: 24),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

private extension ProfileViewController {
    
    @objc
    func didTapExitButton() {
        let logoutAlertPresenter = AlertPresenter(delegate: self)
        let logoutHandler: (UIAlertAction) -> Void = { [weak self] _ in
            guard let self = self else { return }
            self.deleteToken()
            self.switchToSplashViewController()
        }
        let alertModel = AlertModel(
            title: "Пока-пока!",
            message: "Уверены, что хотите выйти?",
            actionTitles: ["Да", "Нет"],
            completions: [logoutHandler])
        logoutAlertPresenter.requestAlert(alertModel)
    }
    
    func setupExitButton() {
        exitButton.addTarget(self, action: #selector(didTapExitButton), for: .touchUpInside)
    }
    
    func deleteToken() {
        let tokenCleaner = TokenCleaner()
        tokenCleaner.clean()
    }
    
    func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Can't retrieve window object")
            return
        }
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
}

extension ProfileViewController: AlertPresenterDelegate {
    func didRecieveAlert(_ vc: UIAlertController) {
        present(vc, animated: true)
    }
}
