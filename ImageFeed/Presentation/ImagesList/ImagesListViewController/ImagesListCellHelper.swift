//
//  ImagesListConfigureCellHelper.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 17.03.2023.
//

import UIKit
import Kingfisher

public protocol ImagesListCellHelperProtocol {
    func configured(
        cell: ImagesListCell,
        at: IndexPath,
        with: Photo,
        completion: @escaping () -> Void
    ) -> ImagesListCell
    func calculateCellHeight(
        at: IndexPath,
        tableViewWidth: CGFloat,
        for: Photo
    ) -> CGFloat
}

struct ImagesListCellHelper: ImagesListCellHelperProtocol {
    func configured(
        cell: ImagesListCell,
        at indexPath: IndexPath,
        with photo: Photo,
        completion: @escaping () -> Void
    ) -> ImagesListCell {
        let configuredCell = configure(cell: cell, at: indexPath, with: photo, completion: completion)
        configuredCell.selectionStyle = .none
        return configuredCell
    }
    
    func calculateCellHeight(
        at indexPath: IndexPath,
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
}

private extension ImagesListCellHelper {
    func configure(
        cell: ImagesListCell,
        at indexPath: IndexPath,
        with photo: Photo,
        completion: @escaping () -> Void
    ) -> ImagesListCell {
        if let imageURL = URL(string: photo.thumbImageURL) {
            setImageFor(cell: cell, with: imageURL, completion: completion)
        }
        cell.cellDateText = photo.createdAt.imagesListCellDateString()
        cell.isLiked = photo.isLiked
        
        return cell
    }
    
    func setImageFor(
        cell: ImagesListCell,
        with imageURL: URL,
        completion rowsReloadingCompletion: @escaping () -> Void
    ) {
        KingfisherManager.shared.retrieveImage(with: imageURL) { result in
            switch result {
            case .success(let imageResult):
                cell.cellState = .finished(imageResult.image)
            case .failure(_):
                cell.cellState = .error
            }

            rowsReloadingCompletion()
        }
    }
}
