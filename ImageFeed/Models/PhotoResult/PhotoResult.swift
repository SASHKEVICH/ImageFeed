//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 18.02.2023.
//

import Foundation

struct PhotoUrlsResult: Decodable {
    let full: String
    let thumb: String
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: Date?
    let width: Int
    let height: Int
    let description: String?
    let likedByUser: Bool
    let urls: PhotoUrlsResult
}
