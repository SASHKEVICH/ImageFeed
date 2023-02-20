//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 17.12.2022.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private let imagesListService: ImagesListService = ImagesListService()
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos: [ImagesListService.Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        addNotificationObserver()
        
        if photos.isEmpty {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            guard
                let indexPath = sender as? IndexPath,
                let imageURL = URL(string: photos[indexPath.row].largeImageURL)
            else { return }
            
            setLargeImage(for: viewController, with: imageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        guard let imageURL = URL(string: photo.regularImageURL) else { return }
        cell.cellImage.kf.setImage(with: imageURL)
        cell.dateLabel.text = DateFormatter.imagesListCellDateFormmater.string(from: photo.createdAt ?? Date())
        cell.isLiked = photo.isLiked
    }
    
}

//MARK: - NotificationCenter methods
private extension ImagesListViewController {

    func updatePhotos() {
        self.photos = imagesListService.photos
        tableView.reloadData()
    }
    
    func addNotificationObserver() {
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updatePhotos()
            }
    }
    
}

private extension ImagesListViewController {
    
    func setLargeImage(for viewController: UIViewController, with url: URL) {
        guard let viewController = viewController as? SingleImageViewController else { return }
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                viewController.image = value.image
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        let isNextCellLast = indexPath.row + 1 == photos.count
        if isNextCellLast {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            print("Something went wrong in \(ImagesListCell.reuseIdentifier)")
            return UITableViewCell()
        }
        
        configCell(for: imagesListCell, with: indexPath)
        return imagesListCell
    }
    
}
