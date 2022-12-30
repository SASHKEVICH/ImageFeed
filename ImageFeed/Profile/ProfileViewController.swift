//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 29.12.2022.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet private weak var profileImage: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var nicknameLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var exitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProfileImage()
    }
    
    private func setupProfileImage() {
        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = profileImage.bounds.height / 2
    }
}
