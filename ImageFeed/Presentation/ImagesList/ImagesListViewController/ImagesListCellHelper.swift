//
//  ImagesListConfigureCellHelper.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 17.03.2023.
//

import UIKit

public protocol ImagesListCellHelperDelegate: AnyObject {
    func didSet(image: UIImage, for cell: ImagesListCell)
    func didSetErrorState(for cell: ImagesListCell)
}

public protocol ImagesListCellHelperProtocol: AnyObject, ImagesListCellHelperDelegate {
    func configured(
        cell: ImagesListCell,
        with: Photo,
        completion: @escaping () -> Void
    ) -> ImagesListCell
    func calculateCellHeight(
        tableViewWidth: CGFloat,
        for: Photo
    ) -> CGFloat
    func setCellLoadingStateIfItsImageNil(_: UITableViewCell)
}

// MARK: - Interface methods
final class ImagesListCellHelper: ImagesListCellHelperProtocol {
    private var imageLoader: ImagesListCellImageLoaderProtocol
    
    init(imageLoader: ImagesListCellImageLoaderProtocol = ImagesListCellImageLoader()) {
        self.imageLoader = imageLoader
        imageLoader.helper = self
    }
    
    func configured(
        cell: ImagesListCell,
        with photo: Photo,
        completion: @escaping () -> Void
    ) -> ImagesListCell {
        let configuredCell = configure(
            cell: cell,
            with: photo,
            completion: completion)
        configuredCell.selectionStyle = .none
        return configuredCell
    }
    
    func calculateCellHeight(
        tableViewWidth: CGFloat,
        for photo: Photo
    ) -> CGFloat {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewWidth - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func setCellLoadingStateIfItsImageNil(_ cell: UITableViewCell) {
        if let cell = cell as? ImagesListCell, cell.cellImage == nil {
            cell.cellState = .loading
        }
    }
}

// MARK: - ImagesListCellHelperDelegate
extension ImagesListCellHelper: ImagesListCellHelperDelegate {
    func didSet(image: UIImage, for cell: ImagesListCell) {
        cell.cellState = .finished(image)
    }
    
    func didSetErrorState(for cell: ImagesListCell) {
        cell.cellState = .error
    }
}

// MARK: - Private helper methods
private extension ImagesListCellHelper {
    func configure(
        cell: ImagesListCell,
        with photo: Photo,
        completion: @escaping () -> Void
    ) -> ImagesListCell {
        imageLoader.requestLoadImage(for: cell, with: photo, completion: completion)
        
        cell.cellDateText = photo.createdAt.imagesListCellDateString()
        cell.isLiked = photo.isLiked
        return cell
    }
}
