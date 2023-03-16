//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 16.03.2023.
//

import UIKit

public protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func didTapExitButton()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    private let profileService = ProfileDescriptionService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    weak var view: ProfileViewControllerProtocol?
    
    
    
}

// MARK: - Logout Methods
extension ProfileViewPresenter: AlertPresenterDelegate {
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

    
    func didRecieveAlert(_ vc: UIAlertController) {
        view?.present(alert: vc)
    }
}
