//
//  ImagesListCellImageLoader.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 18.03.2023.
//

import Foundation
import Kingfisher

public protocol ImagesListCellImageLoaderProtocol: AnyObject {
    var helper: ImagesListCellHelperDelegate? { get set }
    func requestLoadImage(
        for: ImagesListCell,
        with: Photo,
        completion: @escaping () -> Void)
}

final class ImagesListCellImageLoader: ImagesListCellImageLoaderProtocol {
    weak var helper: ImagesListCellHelperDelegate?
    
    func requestLoadImage(
        for cell: ImagesListCell,
        with photo: Photo,
        completion rowsReloadingCompletion: @escaping () -> Void
    ) {
        guard let imageURL = URL(string: photo.thumbImageURL) else { return }
        KingfisherManager.shared.retrieveImage(with: imageURL) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.helper?.didSet(image: imageResult.image, for: cell)
            case .failure:
                self.helper?.didSetErrorState(for: cell)
            }

            rowsReloadingCompletion()
        }
    }
}
