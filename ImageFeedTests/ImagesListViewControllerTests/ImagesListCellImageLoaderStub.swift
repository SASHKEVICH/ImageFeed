//
//  ImagesListCellImageLoaderStub.swift
//  ImageFeedTests
//
//  Created by Александр Бекренев on 18.03.2023.
//

import UIKit
import ImageFeed

final class ImagesListCellImageLoaderStub: ImagesListCellImageLoaderProtocol {
    var helper: ImagesListCellHelperDelegate?
    
    func requestLoadImage(
        for cell: ImagesListCell,
        with photo: Photo,
        completion: @escaping () -> Void
    ) {
        let image = UIImage(systemName: "person.crop.circle")!
        helper?.didSet(image: image, for: cell)
    }
}
