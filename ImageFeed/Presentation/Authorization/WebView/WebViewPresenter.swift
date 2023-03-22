//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 10.03.2023.
//

import Foundation

public protocol WebViewPresenterProtocol: AnyObject {
    func code(from url: URL) -> String?
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    var view: WebViewViewControllerProtocol? { get set }
}

final class WebViewPresenter {
    weak var view: WebViewViewControllerProtocol?
    private let authConfiguration = AuthConfiguration.standard
    private var authHelper: WebViewAuthHelperProtocol
    
    init(helper: WebViewAuthHelperProtocol) {
        self.authHelper = helper
    }
}

// MARK: - WebViewPresenterProtocol
extension WebViewPresenter: WebViewPresenterProtocol {
    func viewDidLoad() {
        didUpdateProgressValue(0)
        guard let authRequest = authHelper.authRequest else { return }
        view?.load(request: authRequest)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
}

private extension WebViewPresenter {
    func createAuthRequest() -> URLRequest? {
        var urlComponents = URLComponents(string: authConfiguration.unsplashOAuthString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: authConfiguration.accessKey),
            URLQueryItem(name: "redirect_uri", value: authConfiguration.redirectURI),
            URLQueryItem(name: "scope", value: authConfiguration.accessScopes),
            URLQueryItem(name: "response_type", value: "code"),
        ]
        urlComponents?.path = "/oauth/authorize"
        
        guard let url = urlComponents?.url else { return nil }
        return URLRequest(url: url)
    }
}
