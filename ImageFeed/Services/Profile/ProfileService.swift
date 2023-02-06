//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 06.02.2023.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private let urlSession: URLSession = URLSession.shared
    private var task: URLSessionTask?
    
    private(set) var profile: Profile?
    
    func fetchProfile(
        token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        if isTaskStillRunning { return }
        let request = profileRequest(token: token)
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

private extension ProfileService {
    
    var isTaskStillRunning: Bool {
        task != nil
    }
    
    func profileRequest(token: String) -> URLRequest {
        let url = createProfileURL()
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func createProfileURL() -> URL? {
        var urlComponents = URLComponents(string: unsplashAPIString)
        urlComponents?.path = "/me"
        return urlComponents?.url
    }
    
    func handle(
        result: Result<ProfileResult, Error>,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        switch result {
        case .success(let profileResult):
            let profile = Profile(from: profileResult)
            self.profile = profile
            completion(.success(profile))
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    func object(
        for request: URLRequest,
        completion: @escaping (Result<ProfileResult, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<ProfileResult, Error> in
                return Result {
                    try decoder.decode(ProfileResult.self, from: data)
                }
            }
            completion(response)
        }
    }
    
}
