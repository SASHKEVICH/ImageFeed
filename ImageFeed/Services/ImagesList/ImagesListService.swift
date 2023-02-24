//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 18.02.2023.
//

import Foundation

final class ImagesListService {
    
    struct Photo {
        let id: String
        let size: CGSize
        let createdAt: Date?
        let welcomeDescription: String?
        let thumbImageURL: String
        let largeImageURL: String
        let isLiked: Bool
        
        init(from result: PhotoResult) {
            self.id = result.id
            self.size = CGSize(width: result.width, height: result.height)
            self.createdAt = result.createdAt
            self.welcomeDescription = result.description
            self.thumbImageURL = result.urls.thumb
            self.largeImageURL = result.urls.full
            self.isLiked = result.likedByUser
        }
    }
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let urlSession = URLSession.shared
    private let token = OAuth2TokenStorage().token
    
    private var fetchPhotosTask: URLSessionTask?
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard !fetchPhotosTask.isStillRunning else { return }
        
        let nextPage = calculateNextPage()
        let request = nextImagesPageRequest(page: nextPage)
        let task = urlSession.startLoadingObjectFromNetwork(with: request) { [weak self] (result: Result<[PhotoResult], Error>) -> Void in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handle(result: result)
                self.fetchPhotosTask = nil
            }
        }
        self.fetchPhotosTask = task
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

private extension ImagesListService {
    
    func handle(result: Result<[PhotoResult], Error>) {
        switch result {
        case .success(let photosResult):
            let photos = photosResult.map { photoResult in Photo(from: photoResult) }
            self.photos += photos
            self.postNotification()
        case .failure(let error):
            print(error)
        }
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
    
    func nextImagesPageRequest(page: Int) -> URLRequest {
        guard var imagesPageUrlComponents = URLComponents(string: unsplashAPIString) else { fatalError("Unable to construct `/photos` url components") }
        imagesPageUrlComponents.path = "/photos"
        imagesPageUrlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        let request = URLRequest.makeHTTPRequest(url: imagesPageUrlComponents.url!, accessToken: token)
        return request
    }
    
}
