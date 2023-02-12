//
//  UserResult.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 07.02.2023.
//

import Foundation

struct UserResult: Decodable {
    struct ProfileImage: Decodable {
        let small: String
    }
    
    let profileImage: ProfileImage
}
