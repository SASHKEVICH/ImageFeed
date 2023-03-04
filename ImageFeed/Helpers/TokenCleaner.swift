//
//  TokenCleaner.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 25.02.2023.
//

import Foundation
import WebKit

struct TokenCleaner {
    private let oauthTokenStorage = OAuth2TokenStorage()
    
    func clean() {
        oauthTokenStorage.clean()
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
           records.forEach { record in
              WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
           }
        }
    }
}
