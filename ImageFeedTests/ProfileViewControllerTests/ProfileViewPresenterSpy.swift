//
//  ProfileViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Александр Бекренев on 16.03.2023.
//

import Foundation
import ImageFeed

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var view: ImageFeed.ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var didExitButtonTapped = false
    
    func didTapExitButton() {
        didExitButtonTapped = true
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func requestUpdateProfileDetails() {}
    
    func requestUpdateProfileAvatar() {}
}
