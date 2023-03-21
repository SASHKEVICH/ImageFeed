//
//  WebViewAuthHelper.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 11.03.2023.
//

import Foundation

protocol WebViewAuthHelperProtocol {
    var authRequest: URLRequest? { get }
    func code(from url: URL) -> String?
}

struct WebViewAuthHelper: WebViewAuthHelperProtocol {
    private let configuration: AuthConfiguration
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    var authURL: URL? {
        var urlComponents = URLComponents(string: configuration.unsplashOAuthString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "scope", value: configuration.accessScopes),
            URLQueryItem(name: "response_type", value: "code"),
        ]
        urlComponents?.path = "/oauth/authorize"
        
        guard let url = urlComponents?.url else { return nil }
        return url
    }
    
    var authRequest: URLRequest? {
        guard let url = authURL else { return nil }
        return URLRequest(url: url)
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
