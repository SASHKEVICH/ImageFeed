//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 26.01.2023.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private lazy var tokenStorage = OAuth2TokenStorage()
    
    private let urlSession: URLSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private(set) var authToken: String? {
        get {
            return tokenStorage.token
        }
        set {
            tokenStorage.token = newValue
        }
    }
    
    func fetchAuthToken(
        with code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        if isLastCodeEqualsNew(code: code) { return }
        task?.cancel()
        
        lastCode = code
        let request = authTokenRequest(code: code)
        let task = object(for: request) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handle(result: result, completion: completion)
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
}

private extension OAuth2Service {
    
    func authTokenRequest(code: String) -> URLRequest {
        let tokenURL = createTokenURL(with: code)
        let request = URLRequest.makeHTTPRequest(url: tokenURL, httpMethod: "POST")
        
        return request
    }
    
    func createTokenURL(with code: String) -> URL {
        var urlComponentes = URLComponents(string: unsplashOAuthString)!
        urlComponentes.queryItems = [
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "client_secret", value: secretKey),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        urlComponentes.path = "/oauth/token"
        
        return urlComponentes.url!
    }
    
    func handle(
        result: Result<OAuthTokenResponseBody, Error>,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        switch result {
        case .success(let body):
            self.authToken = body.accessToken
            completion(.success(body.accessToken))
        case .failure(let error):
            completion(.failure(error))
            self.lastCode = nil
        }
    }
    
    func isLastCodeEqualsNew(code: String?) -> Bool {
        lastCode == code
    }
    
    func object(
        for request: URLRequest,
        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                Result {
                    try decoder.decode(OAuthTokenResponseBody.self, from: data)
                }
            }
            
            completion(response)
        }
    }
    
}
