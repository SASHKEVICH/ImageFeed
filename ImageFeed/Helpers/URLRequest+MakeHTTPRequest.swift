//
//  URLRequest+MakeHTTPRequest.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 26.01.2023.
//

import Foundation

extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String = "GET",
        baseURL: URL = unsplashAPIBaseURL,
        accessToken: String? = nil
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        request.httpMethod = httpMethod
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    static func makeHTTPRequest(
        url: URL = unsplashAPIBaseURL,
        httpMethod: String = "GET",
        accessToken: String? = nil
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
