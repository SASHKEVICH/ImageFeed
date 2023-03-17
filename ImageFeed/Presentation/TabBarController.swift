//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 10.02.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let imagesListViewController = setupImagesListViewController()
        let profileViewController = setupProfileViewController()
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
    
    private func setupImagesListViewController() -> ImagesListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let imagesListPresenter = ImagesListPresenter(helper: ImagesListCellHelper())
        
        imagesListViewController.configure(presenter: imagesListPresenter)
        
        return imagesListViewController
    }
    
    private func setupProfileViewController() -> ProfileViewController {
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfileViewPresenter(helper: ProfileAlertHelper())
        
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil)
        
        return profileViewController
    }
}
