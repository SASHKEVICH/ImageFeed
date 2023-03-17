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
    private var imagesListServiceObserver: NSObjectProtocol?
    
    weak var view: ImagesListViewControllerProtocol?
    
    var photos: [Photo] = []
    
    func viewDidLoad() {
        guard photos.isEmpty else { return }
        requestFetchPhotosNextPage()
    }
    
    init() {
        self.alertPresenter = AlertPresenter()
        alertPresenter?.delegate = self
        addUpdatePhotosNotificationObserver()
    }
}

extension ImagesListPresenter {
    func requestChangeCellLike(at indexPath: IndexPath, isLike: Bool) {
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: isLike) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
            case .failure(_):
                let alertModel = AlertModel(
                    title: "Ошибка сети",
                    message: "Не удалось поставить лайк(",
                    actionTitles: ["OK"])
                self.alertPresenter?.requestAlert(alertModel)
            }
        }
    }
}

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

extension ImagesListPresenter: AlertPresenterDelegate {
    func didRecieve(alert vc: UIAlertController) {
        view?.didRecieve(alert: vc)
    }
}

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

// TODO: - Extract to ImagesListConfigureCellHelper
extension ImagesListPresenter {
    func configured(cell: ImagesListCell, at indexPath: IndexPath) -> ImagesListCell {
        cell.selectionStyle = .none
        configure(cell: cell, with: indexPath)
        return cell
    }
    
    private func configure(cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        guard let imageURL = URL(string: photo.thumbImageURL) else { return }
        KingfisherManager.shared.retrieveImage(with: imageURL) { [weak self] result in
            switch result {
            case .success(let imageResult):
                cell.cellState = .finished(imageResult.image)
            case .failure(_):
                cell.cellState = .error
            }
            
            self?.view?.reloadRows(at: indexPath)
        }
        
        cell.cellDateText = photo.createdAt.imagesListCellDateString()
        cell.isLiked = photo.isLiked
    }
}

extension ImagesListPresenter {
    func calculateCellHeight(at indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewWidth - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}
