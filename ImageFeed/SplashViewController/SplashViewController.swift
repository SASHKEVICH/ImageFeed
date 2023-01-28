//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 27.01.2023.
//

import UIKit

final class SplashViewController: UIViewController {
    
    private let ShowAuthenticationScreenSegueIdentifier = "AuthVCSegue"
    private let ShowImagesListViewControllerIdentifier = "ImagesListVC"
    private let oauthService = OAuth2Service.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let _ = OAuth2TokenStorage().token {
            switchToImagesViewController(withIdentifier: ShowImagesListViewControllerIdentifier)
        } else {
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
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
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else { fatalError("Failed to prepate for \(ShowAuthenticationScreenSegueIdentifier)") }
            
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
}

extension SplashViewController: AuthViewControllerDelegate {
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            self?.fetchAuthToken(code: code)
        }
    }
    
    private func fetchAuthToken(code: String) {
        oauthService.fetchAuthToken(with: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.switchToImagesViewController(withIdentifier: self.ShowImagesListViewControllerIdentifier)
            case .failure(let error):
                // throw InvalidTokenError
                print(error)
            }
        }
    }
    
}
