//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 27.01.2023.
//

import UIKit

final class SplashViewController: UIViewController {
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "LaunchScreenVector")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let authViewControllerIdentifier = "AuthViewController"
    private let tabBarControllerIdentifier = "TabBarController"
    private let oauthService = OAuth2Service.shared
    private let profileService = ProfileDescriptionService.shared
    
    private var authAlertPresenter: AlertPresenterProtocol?
    
    private var token: String? {
        OAuth2TokenStorage().token
    }
    
    private var isTokenInStorage: Bool {
        token != nil
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .ypBlack
        layoutLogo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        authAlertPresenter = AlertPresenter(delegate: self)

        if isTokenInStorage {
            guard let token = token else { return }
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }
    
    private func presentAuthViewController() {
        guard let authViewController = getViewController(withIdentifier: authViewControllerIdentifier) as? AuthViewController
        else { fatalError("Unable to get AuthViewController") }
        
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func switchToTabBarController() {
        guard
            let window = UIApplication.shared.windows.first,
            let tabBarController = getViewController(withIdentifier: tabBarControllerIdentifier) as? TabBarController
        else { fatalError("Invalid configuration") }
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func getViewController(withIdentifier id: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: id)
        return viewController
    }

}

private extension SplashViewController {
    
    func layoutLogo() {
        view.addSubview(logoImageView)
        let constraints = [
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}

extension SplashViewController: AuthViewControllerDelegate {
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            self?.fetchAuthToken(code: code)
        }
    }
    
    private func fetchAuthToken(code: String) {
        oauthService.fetchAuthToken(with: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.fetchProfile(token: token)
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                self.requestAlert()
                print(error)
            }
        }
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token: token) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let profile):
                self.switchToTabBarController()
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
            case .failure(let error):
                self.requestAlert()
                print(error)
            }
        }
    }
    
    private func requestAlert() {
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            actionTitles: ["OK"])
        self.authAlertPresenter?.requestAlert(alertModel)
    }
    
}

extension SplashViewController: AlertPresenterDelegate {
    func didRecieveAlert(_ vc: UIAlertController) {
        present(vc, animated: true)
    }
}
