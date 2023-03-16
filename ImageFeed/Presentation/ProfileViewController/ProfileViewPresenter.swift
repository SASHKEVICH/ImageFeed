//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 16.03.2023.
//

import UIKit
import Kingfisher

public protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func didTapExitButton()
    func requestUpdateProfileDetails()
    func requestUpdateProfileAvatar()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    private let profileService = ProfileDescriptionService.shared
    private let profileImageService = ProfileImageService.shared
    
    private var alertPresenter: AlertPresenterProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    
    weak var view: ProfileViewControllerProtocol?
    
    init() {
        alertPresenter = AlertPresenter()
        alertPresenter?.delegate = self
        
        addUpdateAvatarNotificationObserver()
    }
}

// MARK: - Update Profile Avatar
extension ProfileViewPresenter {
    func requestUpdateProfileAvatar() {
        guard
            let profileImageURL = profileImageService.profileImageURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.view?.didUpdateAvatar(with: imageResult.image)
            case .failure(_):
                if let placeholder = UIImage(systemName: "person.crop.circle") {
                    self.view?.didUpdateAvatar(with: placeholder)
                }
                self.requestImageDownloadingFailureAlert()
            }
        }
    }
    
    private func addUpdateAvatarNotificationObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.requestUpdateProfileAvatar()
            }
    }
    
    private func requestImageDownloadingFailureAlert() {
        let alertModel = AlertModel(
            title: "Ошибка загрузки",
            message: "Не удалось загрузить аватар профиля(",
            actionTitles: ["OK"])
        alertPresenter?.requestAlert(alertModel)
    }
}

// MARK: - Update Profile Details
extension ProfileViewPresenter {
    func requestUpdateProfileDetails() {
        guard let profile = profileService.profile else {
            requestProfileIsEmptyAlert()
            return
        }
        view?.didUpdateProfileDetails(profile: profile)
    }
    
    private func requestProfileIsEmptyAlert() {
        let alertModel = AlertModel(
            title: "Ошибка загрузки",
            message: "Не удалось загрузить информацию профиля(",
            actionTitles: ["OK"])
        alertPresenter?.requestAlert(alertModel)
    }
}

// MARK: - Logout Methods
extension ProfileViewPresenter {
    func didTapExitButton() {
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
        alertPresenter?.requestAlert(alertModel)
    }
    
    private func deleteToken() {
        let tokenCleaner = TokenCleaner()
        tokenCleaner.clean()
    }
    
    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Can't retrieve window object")
            return
        }
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
}

// MARK: - AlertPresenterDelegate
extension ProfileViewPresenter: AlertPresenterDelegate {
    func didRecieveAlert(_ vc: UIAlertController) {
        view?.present(alert: vc)
    }
}
