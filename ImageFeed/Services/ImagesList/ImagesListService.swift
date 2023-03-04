//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 18.02.2023.
//

import Foundation

final class ImagesListService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let urlSession = URLSession.shared
    private let token = OAuth2TokenStorage().token
    
    private var fetchPhotosTask: URLSessionTask?
    private var likeTask: URLSessionTask?
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard !fetchPhotosTask.isStillRunning else { return }
        
        let nextPage = calculateNextPage()
        guard let request = nextImagesPageRequest(page: nextPage) else { return }
        let task = urlSession.startLoadingObjectFromNetwork(with: request) { [weak self] (result: Result<[PhotoResult], Error>) -> Void in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handleFetchingPhotos(result: result)
                self.fetchPhotosTask = nil
            }
        }
        self.fetchPhotosTask = task
        task.resume()
    }
    
    func changeLike(
        photoId: String,
        isLike: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        guard let request = changeLikeRequest(for: photoId, isLike: isLike) else { return }
        let task = urlSession.startLoadingObjectFromNetwork(with: request) { [weak self] (result: Result<LikePhotoResult, Error>) -> Void in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handleChangeLike(result: result, photoId: photoId, completion: completion)
                self.likeTask = nil
            }
        }
        self.likeTask = task
        task.resume()
    }
}

// MARK: NotifationCenter method
private extension ImagesListService {
    func postNotification() {
        NotificationCenter.default
            .post(name: ImagesListService.didChangeNotification,
                  object: self,
                  userInfo: ["photos": photos])
    }
}

// MARK: Fetch Photos methods
private extension ImagesListService {
    
    func handleFetchingPhotos(result: Result<[PhotoResult], Error>) {
        switch result {
        case .success(let photosResult):
            let photos = mapToPhotos(from: photosResult)
            self.photos += photos
            self.postNotification()
        case .failure(let error):
            print(error)
        }
    }
    
    func mapToPhotos(from result: [PhotoResult]) -> [Photo] {
        let photos = result.map { photoResult in
            Photo(id: photoResult.id,
                  size: CGSize(width: photoResult.width, height: photoResult.height),
                  createdAt: photoResult.createdAt,
                  welcomeDescription: photoResult.description,
                  thumbImageURL: photoResult.urls.thumb,
                  largeImageURL: photoResult.urls.full,
                  isLiked: photoResult.likedByUser)
        }
        return photos
    }
    
    func calculateNextPage() -> Int {
        guard var lastLoadedPage = lastLoadedPage else {
            self.lastLoadedPage = 1
            return 1
        }
        lastLoadedPage += 1
        self.lastLoadedPage = lastLoadedPage
        return lastLoadedPage
    }
    
    func nextImagesPageRequest(page: Int) -> URLRequest? {
        guard var imagesPageUrlComponents = URLComponents(string: Constants.unsplashAPIString) else {
            assertionFailure("Unable to construct `/photos` url components")
            return nil
        }
        imagesPageUrlComponents.path = "/photos"
        imagesPageUrlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        let request = URLRequest.makeHTTPRequest(url: imagesPageUrlComponents.url!, accessToken: token)
        return request
    }
}

// MARK: Change like methods
private extension ImagesListService {
    
    func handleChangeLike(result: Result<LikePhotoResult, Error>, photoId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        switch result {
        case .success:
            changePhotoLikedState(photoId: photoId)
            completion(.success(()))
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    func changePhotoLikedState(photoId: String) {
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
    }
    
    func changeLikeRequest(for id: String, isLike: Bool) -> URLRequest? {
        guard var changeLikeUrlComponents = URLComponents(string: Constants.unsplashAPIString) else {
            assertionFailure("Unable to construct `/photos/like` url components")
            return nil
        }
        changeLikeUrlComponents.path = "/photos/\(id)/like"
        let request = URLRequest.makeHTTPRequest(path: "/photos/\(id)/like", httpMethod: isLike ? "POST" : "DELETE", accessToken: token)
        return request
    }
}
