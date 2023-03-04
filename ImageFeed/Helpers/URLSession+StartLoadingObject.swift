//
//  URLSession+StartLoadingObject.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 08.02.2023.
//

import Foundation

extension URLSession {
    func startLoadingObjectFromNetwork<T: Decodable>(
        with request: URLRequest,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = dateDecodingStrategy
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
