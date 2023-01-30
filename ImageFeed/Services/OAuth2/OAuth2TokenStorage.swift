//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 27.01.2023.
//

import Foundation

struct OAuth2TokenStorage {
    
    private let defaults = UserDefaults.standard
    
    var token: String? {
        get {
            return defaults.string(forKey: "bearerToken")
        }
        set {
            defaults.set(newValue, forKey: "bearerToken")
        }
    }
    
}
