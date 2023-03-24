//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Александр Бекренев on 16.03.2023.
//

import UIKit
import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    func switchToSplashViewController() {}
    
    func didRecieve(alert: UIAlertController) {}
    
    var presenter: ImageFeed.ProfileViewPresenterProtocol?
    var image: UIImage?
    var loginName: String?
    var name: String?
    
    func present(alert: UIAlertController) {}
    
    func didUpdateProfileDetails(profile: Profile) {
        self.loginName = profile.loginName
        self.name = profile.name
    }
    
    func didUpdateAvatar(with image: UIImage) {
        self.image = image
    }
}
