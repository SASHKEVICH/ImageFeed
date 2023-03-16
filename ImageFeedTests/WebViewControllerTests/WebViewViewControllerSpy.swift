//
//  WebViewViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Александр Бекренев on 11.03.2023.
//

import Foundation
import ImageFeed

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var didPresenterCallLoad: Bool = false
    
    func load(request: URLRequest) {
        didPresenterCallLoad = true
    }
    
    func setProgressValue(_ newValue: Float) {}
    
    func setProgressHidden(_ isHidden: Bool) {}
}
