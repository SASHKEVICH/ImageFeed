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
    
    private let urlSession: URLSession = URLSession.shared
    private lazy var tokenStorage = OAuth2TokenStorage()
    
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
        let completionInMainThread: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let request = authTokenRequest(code: code)
        
        let task = object(for: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                self.authToken = body.accessToken
                completionInMainThread(.success(body.accessToken))
            case .failure(let error):
                completionInMainThread(.failure(error))
            }
        }
        task.resume()
    }
    
    private func authTokenRequest(code: String) -> URLRequest {
        let tokenURL = createTokenURL(with: code)
        let request = URLRequest.makeHTTPRequest(url: tokenURL, httpMethod: "POST")
        
        return request
    }
    
    private func createTokenURL(with code: String) -> URL {
        var urlComponentes = URLComponents(string: UnsplashOAuthString)!
        urlComponentes.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "client_secret", value: SecretKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        urlComponentes.path = "/oauth/token"
        
        return urlComponentes.url!
    }
    
}

extension OAuth2Service {
    
    private func object(
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
