//
//  URLSession+StartLoadingObject.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 08.02.2023.
//

import Foundation

extension URLSession {
    
    func startLoadingObject<T: Decodable>(
        from request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<T, Error> in
                Result {
                    try decoder.decode(T.self, from: data)
                }
            }
            completion(response)
        }
    }
    
}
