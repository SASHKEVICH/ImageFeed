//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 17.12.2022.
//

import UIKit

public protocol ImagesListViewControllerProtocol: AnyObject {
    func didUpdatePhotosAnimated(_ photos: [Photo])
    func didRecieve(alert: UIAlertController)
    func reloadRows(at: IndexPath)
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    @IBOutlet private weak var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var presenter: ImagesListPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        presenter?.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            guard
                let indexPath = sender as? IndexPath,
                let photo = presenter?.photos[indexPath.row],
                let imageURL = URL(string: photo.largeImageURL)
            else { return }
            
            viewController.fullImageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    func configure(presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
}

//MARK: - Update Photos Animated
extension ImagesListViewController {
    func didUpdatePhotosAnimated(_ photos: [Photo]) {
        tableView.performBatchUpdates { [weak self] in
            let batchAmount = 10
            let photosIndexPaths = (photos.count - batchAmount..<photos.count).map { row in
                IndexPath(row: row, section: 0)
            }
            self?.tableView.insertRows(at: photosIndexPaths, with: .automatic)
        } completion: { _ in }
    }
}

//MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.requestChangeCellLike(at: indexPath, isLike: cell.isLiked)
    }
}

//MARK: - Recieving Alerts
extension ImagesListViewController {
    func didRecieve(alert: UIAlertController) {
        present(alert, animated: true)
    }
}

//MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        presenter?.calculateCellHeight(at: indexPath, tableViewWidth: tableView.bounds.width) ?? 0
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        setCellStateIfItsImageNil(cell)
        presenter?.requestFetchPhotosNextPageIfLastCell(at: indexPath)
    }
    
    func setCellStateIfItsImageNil(_ cell: UITableViewCell) {
        if let cell = cell as? ImagesListCell, cell.cellImage == nil {
            cell.cellState = .loading
        }
    }
}

//MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photos.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard
            let imagesListCell = cell as? ImagesListCell,
            let configuredImagesListCell = presenter?.configured(cell: imagesListCell, at: indexPath)
        else {
            assertionFailure("Something went wrong in \(ImagesListCell.reuseIdentifier)")
            return UITableViewCell()
        }
        configuredImagesListCell.delegate = self
        return configuredImagesListCell
    }
    
    func reloadRows(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
