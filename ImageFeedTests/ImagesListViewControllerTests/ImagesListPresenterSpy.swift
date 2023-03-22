//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Александр Бекренев on 17.03.2023.
//

import UIKit
import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func requestFetchPhotosNextPageIfLastCell(at indexPath: IndexPath) {}
    
    func requestChangeCellLike(at indexPath: IndexPath, isLike: Bool) {}
    
    func configured(
        cell: ImageFeed.ImagesListCell,
        at indexPath: IndexPath
    ) -> ImagesListCell {
        ImagesListCell(frame: .zero)
    }
    
    func calculateCellHeight(at indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        0
    }
    
    func setCellLoadingStateIfItsImageNil(_: UITableViewCell) {}
}
