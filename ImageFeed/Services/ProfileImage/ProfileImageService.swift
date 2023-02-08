//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 07.02.2023.
//

import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private init() {}
    
    private let urlSession = URLSession.shared
    private let token = OAuth2TokenStorage().token
    private var task: URLSessionTask?
    
    private(set) var profileImageURL: String?
    
    func fetchProfileImageURL(
        username: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        guard isTaskStillRunning, let token = token else { return }
        
        let request = profileImageRequest(username: username, token: token)
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

private extension ProfileImageService {
    
    var isTaskStillRunning: Bool {
        task != nil
    }
    
    func handle(
        result: Result<UserResult, Error>,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        switch result {
        case .success(let userResult):
            self.profileImageURL = userResult.profileImage.small
            completion(.success(userResult.profileImage.small))
            postNotification()
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    func postNotification() {
        guard let profileImageURL = profileImageURL else { return }
        NotificationCenter.default
            .post(name: ProfileImageService.didChangeNotification,
                  object: self,
                  userInfo: ["URL": profileImageURL])
    }
    
    func profileImageRequest(username: String, token: String) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(path: "/users/\(username)", httpMethod: "GET")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func object(
        for request: URLRequest,
        completion: @escaping (Result<UserResult, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<UserResult, Error> in
                return Result {
                    try decoder.decode(UserResult.self, from: data)
                }
            }
            completion(response)
        }
    }
    
}
