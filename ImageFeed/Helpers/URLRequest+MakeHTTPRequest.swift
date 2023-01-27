//
//  URLRequest+MakeHTTPRequest.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 26.01.2023.
//

import Foundation

fileprivate let DefaultBaseURL = URL(string: "https://api.unsplash.com")!

extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL = DefaultBaseURL
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        request.httpMethod = httpMethod
        return request
    }
    
    static func makeHTTPRequest(
        url: URL,
        httpMethod: String
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        return request
    }
}