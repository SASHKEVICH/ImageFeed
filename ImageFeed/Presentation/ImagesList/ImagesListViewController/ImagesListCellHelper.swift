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
    func setCellLoadingStateIfItsImageNil(_: UITableViewCell)
}

public enum RetrievingImageConfiguration {
    case test(UIImage)
    case production
}

// MARK: - Interface methods
struct ImagesListCellHelper: ImagesListCellHelperProtocol {
    private let retrievingImageConfiguration: RetrievingImageConfiguration
    
    init(configuration: RetrievingImageConfiguration = .production) {
        retrievingImageConfiguration = configuration
    }
    
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
    
    func setCellLoadingStateIfItsImageNil(_ cell: UITableViewCell) {
        if let cell = cell as? ImagesListCell, cell.cellImage == nil {
            cell.cellState = .loading
        }
    }
}

// MARK: - Internal helper methods
extension ImagesListCellHelper {
    func set(image: UIImage, for cell: ImagesListCell) {
        cell.cellState = .finished(image)
    }
    
    func setErrorState(for cell: ImagesListCell) {
        cell.cellState = .error
    }
}

// MARK: - Private helper methods
private extension ImagesListCellHelper {
    func configure(
        cell: ImagesListCell,
        at indexPath: IndexPath,
        with photo: Photo,
        completion: @escaping () -> Void
    ) -> ImagesListCell {
        configureImage(for: cell, with: photo, completion: completion)
        cell.cellDateText = photo.createdAt.imagesListCellDateString()
        cell.isLiked = photo.isLiked
        return cell
    }
    
    func downloadImageFor(
        cell: ImagesListCell,
        with imageURL: URL,
        completion rowsReloadingCompletion: @escaping () -> Void
    ) {
        KingfisherManager.shared.retrieveImage(with: imageURL) { result in
            switch result {
            case .success(let imageResult):
                set(image: imageResult.image, for: cell)
            case .failure(_):
                setErrorState(for: cell)
            }

            rowsReloadingCompletion()
        }
    }
    
    func configureImage(
        for cell:
        ImagesListCell,
        with photo: Photo,
        completion: @escaping () -> Void
    ) {
        switch retrievingImageConfiguration {
        case .production:
            guard let imageURL = URL(string: photo.thumbImageURL) else { return }
            downloadImageFor(cell: cell, with: imageURL, completion: completion)
        case .test(let image):
            set(image: image, for: cell)
        }
    }
}
