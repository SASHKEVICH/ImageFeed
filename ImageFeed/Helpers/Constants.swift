//
//  Constants.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 22.01.2023.
//

import Foundation

struct Constants {
    static let accessKey = "eKVDZrFSvICDbGxnM_8dJnQ_0Smh9Xxxehq3jS5seds"
    static let secretKey = "rwJzVgnKH_TL4hEYsThbZlBzwG83uTY1FHS0CQPhTck"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"

    static let accessScopes = "public+read_user+write_likes"
    static let unsplashOAuthString = "https://unsplash.com/oauth"
    static let unsplashAPIString = "https://api.unsplash.com"
    static let unsplashAPIBaseURL = URL(string: unsplashAPIString)!
}
