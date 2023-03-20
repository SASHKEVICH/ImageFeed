//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 29.12.2022.
//

import UIKit

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func present(alert: UIAlertController)
    func didUpdateProfileDetails(profile: Profile)
    func didUpdateAvatar(with image: UIImage)
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    private var animationViews = Set<UIView>()
    
    var presenter: ProfileViewPresenterProtocol?
    
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
        addActionToExitButton()
        
        showLoadingAnimation()
        
        presenter?.viewDidLoad()
        presenter?.requestUpdateProfileDetails()
        presenter?.requestUpdateProfileAvatar()
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
        addGradientsToSet(gradientViews)
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
    
    func addGradientsToSet(_ gradients: [LoadingGradientAnimationView]) {
        gradients.forEach { loadingView in animationViews.insert(loadingView) }
    }
    
    func addToProfileViews(gradients: [LoadingGradientAnimationView]) {
        profileImageView.addSubview(gradients[0])
        nameLabel.addSubview(gradients[1])
        loginNameLabel.addSubview(gradients[2])
    }
}

//MARK: - Layout Methods
private extension ProfileViewController {
    
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
        
        nameLabel.accessibilityIdentifier = "ProfileNameLabel"
        loginNameLabel.accessibilityIdentifier = "ProfileLoginNameLabel"
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
        exitButton.accessibilityIdentifier = "ProfileExitButton"
    }
}

//MARK: - Update Profile Avatar and Details
extension ProfileViewController {
    func didUpdateAvatar(with image: UIImage) {
        profileImageView.image = image
        hideLoadingAnimation()
    }
    
    func didUpdateProfileDetails(profile: Profile) {
        loginNameLabel.text = profile.loginName
        nameLabel.text = profile.name
    }
}

// MARK: - Logout Methods
extension ProfileViewController {
    @objc
    func didTapExitButton() {
        presenter?.didTapExitButton()
    }
    
    private func addActionToExitButton() {
        exitButton.addTarget(self, action: #selector(didTapExitButton), for: .touchUpInside)
    }
}

extension ProfileViewController {
    func present(alert: UIAlertController) {
        present(alert, animated: true)
    }
}
