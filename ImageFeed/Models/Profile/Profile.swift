//
//  Profile.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 06.02.2023.
//

import Foundation

public struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(from result: ProfileResult) {
        self.username = result.username
        self.name = "\(result.firstName) \(result.lastName)"
        self.loginName = "@\(username)"
        self.bio = result.bio
    }
}
