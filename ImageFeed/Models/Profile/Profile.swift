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
    
    static func convert(from result: ProfileResult) -> Profile {
        let profile = Profile(
            username: result.username,
            name: "\(result.firstName) \(result.lastName)",
            loginName: "@\(result.username)",
            bio: result.bio)
        return profile
    }
}
