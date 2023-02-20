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
        baseURL: URL = unsplashAPIBaseURL
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        request.httpMethod = httpMethod
        return request
    }
    
    static func makeHTTPRequest(
        baseURL: URL = unsplashAPIBaseURL,
        httpMethod: String = "GET"
    ) -> URLRequest {
        var request = URLRequest(url: baseURL)
        request.httpMethod = httpMethod
        return request
    }
}
