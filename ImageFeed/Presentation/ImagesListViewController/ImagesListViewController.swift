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
    private var photos: [Photo] = []
    
    private var alertPresenter: AlertPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        self.alertPresenter = AlertPresenter(delegate: self)
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
            
            viewController.fullImageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

//MARK: - NotificationCenter methods
private extension ImagesListViewController {

    func updatePhotosAnimated() {
        self.photos = imagesListService.photos
        tableView.performBatchUpdates { [weak self] in
            let batchAmount = 10
            let photosIndexPaths = (photos.count - batchAmount..<photos.count).map { row in
                IndexPath(row: row, section: 0)
            }
            self?.tableView.insertRows(at: photosIndexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    func addNotificationObserver() {
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updatePhotosAnimated()
            }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: cell.isLiked) {[weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
            case .failure(let error):
                let alertModel = AlertModel(
                    title: "Ошибка сети",
                    message: "Не удалось поставить лайк(",
                    actionTitles: ["OK"])
                self.alertPresenter?.requestAlert(alertModel)
                print(error)
            }
        }
    }
}

extension ImagesListViewController: AlertPresenterDelegate {
    func didRecieveAlert(_ vc: UIAlertController) {
        present(vc, animated: true)
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
        if let cell = cell as? ImagesListCell, cell.cellImage == nil {
            cell.cellState = .loading
        }
        
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
        cell.selectionStyle = .none
        
        guard let imagesListCell = cell as? ImagesListCell else {
            print("Something went wrong in \(ImagesListCell.reuseIdentifier)")
            return UITableViewCell()
        }
        
        configCell(for: imagesListCell, with: indexPath)

        return imagesListCell
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        guard let imageURL = URL(string: photo.thumbImageURL) else { return }
        KingfisherManager.shared.retrieveImage(with: imageURL) { [weak self] result in
            switch result {
            case .success(let imageResult):
                cell.cellState = .finished(imageResult.image)
            case .failure(_):
                cell.cellState = .error
            }
            
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        cell.cellDateText = photo.createdAt.imagesListCellDateString()
        cell.isLiked = photo.isLiked
        cell.delegate = self
    }
}
