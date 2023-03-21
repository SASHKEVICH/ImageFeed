//
//  ProfileViewTests.swift
//  ProfileViewTests
//
//  Created by Александр Бекренев on 16.03.2023.
//

import XCTest
import UIKit
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testViewControllerShowsRightLoginAndName() {
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter(helper: ProfileAlertHelper())

        viewController.presenter = presenter
        presenter.view = viewController
        
        let expectedLogin = "@sashkevich"
        let expectedName = "Aleksandr Bekrenev"
        let profile = Profile(username: "sashkevich", name: expectedName, loginName: expectedLogin, bio: nil)
        presenter.updateDetailsForView(with: profile)
        
        let actualLogin = viewController.loginName
        let actualName = viewController.name
        
        XCTAssertEqual(expectedLogin, actualLogin)
        XCTAssertEqual(expectedName, actualName)
    }

    func testViewControllerShowsRightImage() {
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter(helper: ProfileAlertHelper())

        viewController.presenter = presenter
        presenter.view = viewController
        
        guard let expectedImage = UIImage(systemName: "person.crop.circle.fill") else {
            XCTFail("Wrong system name for image")
            return
        }
        presenter.updateProfileImageForView(with: expectedImage)
        
        let actualImage = viewController.image
        
        XCTAssertEqual(expectedImage, actualImage)
    }
    
    func testExitButtonHasLogoutAction() {
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()

        viewController.presenter = presenter
        presenter.view = viewController
        
        viewController.didTapExitButton()
        
        XCTAssertTrue(presenter.didExitButtonTapped)
    }
}
