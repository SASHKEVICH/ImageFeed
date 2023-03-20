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
        loginTextField.typeText("praise2001@icloud.com")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("dywPes-vacgud-razdy8")
        webView.swipeUp()
        
        print(app.debugDescription)
        
        let loginButton = webView.descendants(matching: .button).element
        loginButton.tap()
        
        let tables = app.tables
        let cell = tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        
    }
    
    func testProfile() throws {
        
    }
}
