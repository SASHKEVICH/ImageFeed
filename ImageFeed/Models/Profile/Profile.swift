//
//  Profile.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 06.02.2023.
//

import Foundation

public struct Profile {
    public let loginName: String
    public let name: String
    public let username: String
    let bio: String?
    
    static func convert(from result: ProfileResult) -> Profile {
        let profile = Profile(
            loginName: "@\(result.username)",
            name: "\(result.firstName) \(result.lastName)",
            username: result.username,
            bio: result.bio)
        return profile
    }
}
