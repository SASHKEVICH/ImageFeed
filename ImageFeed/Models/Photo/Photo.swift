//
//  Photo.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 03.03.2023.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}
