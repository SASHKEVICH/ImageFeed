//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 10.03.2023.
//

import Foundation

protocol WebViewPresenterProtocol: AnyObject {
    func code(from url: URL) -> String?
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    var view: WebViewViewControllerProtocol? { get set }
}

final class WebViewPresenter: WebViewPresenterProtocol {
    
    weak var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        didUpdateProgressValue(0)
        guard let authorizeRequest = createAuthorizeRequest() else { return }
        view?.load(request: authorizeRequest)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func code(from url: URL) -> String? {
        guard
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        else { return nil }
        
        return codeItem.value
    }
}

private extension WebViewPresenter {
    func createAuthorizeRequest() -> URLRequest? {
        var urlComponents = URLComponents(string: Constants.unsplashOAuthString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "scope", value: Constants.accessScopes),
            URLQueryItem(name: "response_type", value: "code"),
        ]
        urlComponents?.path = "/oauth/authorize"
        
        guard let url = urlComponents?.url else { return nil }
        return URLRequest(url: url)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
}
