//
//  WebViewTests.swift
//  WebViewTests
//
//  Created by Александр Бекренев on 11.03.2023.
//

@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        let viewController = WebViewViewControllerSpy()
        let authHelper = WebViewAuthHelper()
        let presenter = WebViewPresenter(helper: authHelper)
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(viewController.didPresenterCallLoad)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        let helper = WebViewAuthHelper()
        let presenter = WebViewPresenter(helper: helper)
        let progress: Float = 0.6
        
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        let helper = WebViewAuthHelper()
        let presenter = WebViewPresenter(helper: helper)
        let progress: Float = 1
        
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        let configuration = AuthConfiguration.standard
        let helper = WebViewAuthHelper(configuration: configuration)
        
        guard let url = helper.authURL() else {
            XCTFail("Unable to get url")
            return
        }
        let urlString = url.absoluteString
        
        XCTAssertTrue(urlString.contains(configuration.unsplashOAuthString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScopes))
    }
    
    func testCodeFromURL() {
        let originUrl = URL(string: "https://unsplash.com/oauth/authorize/native")!
        let expectedCode = "test code"
        var urlComponents = URLComponents(url: originUrl, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "code", value: expectedCode)
        ]
        
        let fullTestUrl = urlComponents?.url
        
        let helper = WebViewAuthHelper()
        guard let actualCode = helper.code(from: fullTestUrl!) else {
            XCTFail("Actual code is nil")
            return
        }
        
        XCTAssertEqual(actualCode, expectedCode)
    }
}
