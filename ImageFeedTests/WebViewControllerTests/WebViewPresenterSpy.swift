//
//  WebViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Александр Бекренев on 11.03.2023.
//

import ImageFeed
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func code(from url: URL) -> String? { return nil }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {}
}
