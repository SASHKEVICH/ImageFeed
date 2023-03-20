//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Александр Бекренев on 19.03.2023.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["AuthenticateButton"].tap()
        
        let webView = app.webViews["AuthenticateWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        // Да, я знаю, что спалил креды от Unsplash :)
        loginTextField.typeText("Тут-должен-быть-ваш-email")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("Тут-должен-быть-ваш-пароль")
        webView.swipeUp()
        
        print(app.debugDescription)
        
        let loginButton = webView.descendants(matching: .button).element
        loginButton.tap()
        
        let tables = app.tables
        let cell = tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        XCTAssertTrue(cell.waitForExistence(timeout: 2))
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["like button off"].tap()
        sleep(2)
        cellToLike.buttons["like button on"].tap()
        sleep(2)
        cellToLike.tap()
        
        sleep(5)
        
        let image = app.scrollViews.images.element(boundBy: 0)

        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["SingleImageBackButton"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        let nameLabel = app.staticTexts["ProfileNameLabel"]
        let loginNameLabel = app.staticTexts["ProfileLoginNameLabel"]
        XCTAssertTrue(nameLabel.exists)
        XCTAssertTrue(loginNameLabel.exists)
        
        let exitButton = app.buttons["ProfileExitButton"]
        exitButton.tap()
        
        app.alerts["Пока-пока!"].scrollViews.otherElements.buttons["Да"].tap()
        
        sleep(2)
        
        XCTAssertTrue(app.buttons["AuthenticateButton"].exists)
    }
}
