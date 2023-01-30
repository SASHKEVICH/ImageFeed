//
//  URLSession+DataTask.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 26.01.2023.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionDataTask {
        let fulfillCompletion: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        func handle(error: Error?, completion: (Result<Data, Error>) -> Void) {
            if let error = error {
                completion(.failure(NetworkError.urlRequestError(error)))
            } else {
                completion(.failure(NetworkError.urlSessionError))
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            guard
                let data = data,
                let response = response,
                let statusCode = (response as? HTTPURLResponse)?.statusCode
            else {
                handle(error: error, completion: fulfillCompletion)
                return
            }
            
            if 200..<300 ~= statusCode {
                fulfillCompletion(.success(data))
            } else {
                fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
            }
        }
        
        task.resume()
        return task
    }
}
