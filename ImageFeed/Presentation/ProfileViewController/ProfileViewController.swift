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
    
    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 23)
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
        updateProfileDetails(profile: profileService.profile)
        
        addNotificationObserver()
        updateAvatar()
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
        deleteToken()
        switchToSplashViewController()
    }
    
    func setupExitButton() {
        exitButton.addTarget(self, action: #selector(didTapExitButton), for: .touchUpInside)
    }
    
    func deleteToken() {
        let tokenCleaner = TokenCleaner()
        tokenCleaner.clean()
    }
    
    func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Couldn't retrieve window object") }
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
    
}
