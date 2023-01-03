//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 29.12.2022.
//

import UIKit

final class ProfileViewController: UIViewController {
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
    
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textLabel: UILabel = {
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
        
        layoutStackView()
        layoutExitButton()
    }
    
    private func layoutStackView() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(profileImageView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(nicknameLabel)
        stackView.addArrangedSubview(textLabel)
        
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        stackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 235).isActive = true
        
        layoutProfileImageView()
        layoutNameLabel()
        layoutNicknameLabel()
        layoutTextLabel()
    }
    
    private func layoutProfileImageView() {
        let widthAndHeight: CGFloat = 70
        
        let constraints = [
            profileImageView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: widthAndHeight),
            profileImageView.heightAnchor.constraint(equalToConstant: widthAndHeight),
        ]
        NSLayoutConstraint.activate(constraints)
        profileImageView.layer.cornerRadius = widthAndHeight / 2
    }
    
    private func layoutNameLabel() {
        nameLabel.text = "Александр Бекренев"
    }
    
    private func layoutNicknameLabel() {
        nicknameLabel.text = "@sashkevich"
    }
    
    private func layoutTextLabel() {
        textLabel.text = "Hello, World!"
    }
    
    private func layoutExitButton() {
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
    }
}
