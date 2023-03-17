//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 16.03.2023.
//

import UIKit
import Kingfisher

public protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get set }
    func viewDidLoad()
    func requestFetchPhotosNextPageIfLastCell(at indexPath: IndexPath)
    func requestChangeCellLike(at indexPath: IndexPath, isLike: Bool)
    func configured(cell: ImagesListCell, at indexPath: IndexPath) -> ImagesListCell
    func calculateCellHeight(at indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    private let imagesListService: ImagesListService = ImagesListService()
    private var alertPresenter: AlertPresenter?
    private var helper: ImagesListCellHelperProtocol
    private var imagesListServiceObserver: NSObjectProtocol?
    
    weak var view: ImagesListViewControllerProtocol?
    
    var photos: [Photo] = []
    
    func viewDidLoad() {
        self.alertPresenter = AlertPresenter()
        alertPresenter?.delegate = self
        
        guard photos.isEmpty else { return }
        requestFetchPhotosNextPage()
    }
    
    init(helper: ImagesListCellHelperProtocol) {
        self.helper = helper
        addUpdatePhotosNotificationObserver()
    }
}

// MARK: - Request Change Like
extension ImagesListPresenter {
    func requestChangeCellLike(at indexPath: IndexPath, isLike: Bool) {
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: isLike) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            self?.handleChangeLike(result: result)
        }
    }
    
    private func handleChangeLike(result: Result<Void, Error>) {
        switch result {
        case .success:
            self.photos = self.imagesListService.photos
        case .failure(_):
            requestChangeLikeAlert()
        }
    }
    
    private func requestChangeLikeAlert() {
        let alertModel = AlertModel(
            title: "Ошибка сети",
            message: "Не удалось поставить лайк(",
            actionTitles: ["OK"])
        alertPresenter?.requestAlert(alertModel)
    }
}

// MARK: - Photos Fetching
extension ImagesListPresenter {
    func requestFetchPhotosNextPageIfLastCell(at indexPath: IndexPath) {
        let isNextCellLast = indexPath.row + 1 == photos.count
        if isNextCellLast {
            requestFetchPhotosNextPage()
        }
    }
    
    func requestFetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
}

// MARK: - AlertPresenterDelegate
extension ImagesListPresenter: AlertPresenterDelegate {
    func didRecieve(alert vc: UIAlertController) {
        view?.didRecieve(alert: vc)
    }
}

// MARK: - Subscribing to Notifications
extension ImagesListPresenter {
    private func addUpdatePhotosNotificationObserver() {
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                let photos = self.imagesListService.photos
                self.photos = photos
                self.view?.didUpdatePhotosAnimated(photos)
            }
    }
}

// MARK: - Cell Configuring with Helper
extension ImagesListPresenter {
    func configured(cell: ImagesListCell, at indexPath: IndexPath) -> ImagesListCell {
        let photo = photos[indexPath.row]
        let configuredCell = helper.configured(cell: cell, at: indexPath, with: photo) { [weak self] in
            self?.view?.reloadRows(at: indexPath)
        }
        return configuredCell
    }
    
    func calculateCellHeight(at indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        let photo = photos[indexPath.row]
        let cellHeight = helper.calculateCellHeight(at: indexPath, tableViewWidth: tableViewWidth, for: photo)
        return cellHeight
    }
}
