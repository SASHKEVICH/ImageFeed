//
//  ImagesListServiceSpy.swift
//  ImageFeedTests
//
//  Created by Александр Бекренев on 19.03.2023.
//

import Foundation
@testable import ImageFeed

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    var didChangeNotificationName: Notification.Name = Notification.Name("ImagesListServiceDidChange")
    var photos: [Photo] = []
    
    var didCalledFetchPhotosNextPage = false
    
    func fetchPhotosNextPage() {
        didCalledFetchPhotosNextPage = true
        let dummyPhoto = Photo(
            id: "123",
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "nil",
            largeImageURL: "nil",
            isLiked: false)
        self.photos.append(dummyPhoto)
        postNotification()
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let index = self.photos.firstIndex(where: { $0.id == photoId }) else { return }
        let photo = self.photos[index]
        let newPhoto = Photo(
            id: photo.id,
            size: photo.size,
            createdAt: photo.createdAt,
            welcomeDescription: photo.welcomeDescription,
            thumbImageURL: photo.thumbImageURL,
            largeImageURL: photo.largeImageURL,
            isLiked: !photo.isLiked)
        self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
        completion(.success(()))
    }
    
    private func postNotification() {
        NotificationCenter.default
            .post(name: didChangeNotificationName,
                  object: self,
                  userInfo: ["photos": photos])
    }
}
