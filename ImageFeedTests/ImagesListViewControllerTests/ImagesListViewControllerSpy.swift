//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Александр Бекренев on 19.03.2023.
//

import UIKit
import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    var didUpdatePhotosAnimatedCalled = false
    
    func didUpdatePhotosAnimated(photosCount: Int) {
        didUpdatePhotosAnimatedCalled = true
    }
    
    func didRecieve(alert: UIAlertController) {}
    
    func reloadRows(at: IndexPath) {}
}
