//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 27.01.2023.
//

import Foundation
import SwiftKeychainWrapper

struct OAuth2TokenStorage {
    
    private let keyChain = KeychainWrapper.standard
    private let key = "bearerToken"
    
    var token: String? {
        get {
            return keyChain.string(forKey: key)
        }
        set {
            guard let token = newValue else { return }
            keyChain.set(token, forKey: key)
        }
    }
    
}
