//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 25.01.2023.
//

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
