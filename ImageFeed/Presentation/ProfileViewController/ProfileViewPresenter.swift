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
    func viewDidLoad()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    private let profileService = ProfileDescriptionService.shared
    private let profileImageService = ProfileImageService.shared
    private let profileAlertHelper: ProfileAlertHelperProtocol
    
    private var alertPresenter: AlertPresenterProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    
    weak var view: ProfileViewControllerProtocol?
    
    init(helper: ProfileAlertHelperProtocol) {
        profileAlertHelper = helper
    }
    
    func viewDidLoad() {
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
                self.updateProfileImageForView(with: imageResult.image)
            case .failure(_):
                if let placeholder = UIImage(systemName: "person.crop.circle.fill") {
                    self.updateProfileImageForView(with: placeholder)
                }
                self.requestImageDownloadingFailureAlert()
            }
        }
    }
    
    func updateProfileImageForView(with image: UIImage) {
        view?.didUpdateAvatar(with: image)
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
        let alertModel = profileAlertHelper.imageDownloadingFailureAlertModel()
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
        updateDetailsForView(with: profile)
    }
    
    func updateDetailsForView(with profile: Profile) {
        view?.didUpdateProfileDetails(profile: profile)
    }
    
    private func requestProfileIsEmptyAlert() {
        let alertModel = profileAlertHelper.profileIsEmptyAlertModel()
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
        let logoutAlertModel = profileAlertHelper.exitButtonAlertModel(logoutHandler: logoutHandler)
        alertPresenter?.requestAlert(logoutAlertModel)
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
