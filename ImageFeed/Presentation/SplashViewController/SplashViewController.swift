//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 27.01.2023.
//

import UIKit

final class SplashViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "AuthVCSegue"
    private let showImagesListViewControllerIdentifier = "ImagesListVC"
    private let oauthService = OAuth2Service.shared
    private let profileService = ProfileService.shared
    
    private var alertPresenter = AlertPresenter()
    
    private var token: String? {
        OAuth2TokenStorage().token
    }
    
    private var isTokenInStorage: Bool {
        token != nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        alertPresenter.delegate = self

        if isTokenInStorage {
            guard let token = token else { return }
            fetchProfile(token: token)
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToImagesViewController(withIdentifier id: String) {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid configuration") }
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: id)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }

}

extension SplashViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else { fatalError("Failed to prepate for \(showAuthenticationScreenSegueIdentifier)") }
            
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
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
                self.alertPresenter.requestAlert()
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
                self.switchToImagesViewController(withIdentifier: self.showImagesListViewControllerIdentifier)
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
            case .failure(let error):
                self.alertPresenter.requestAlert()
                print(error)
            }
        }
    }
    
}

extension SplashViewController: AlertPresenterDelegate {
    
    func didRecieveAlert(_ vc: UIAlertController) {
        present(vc, animated: true)
    }
    
}
