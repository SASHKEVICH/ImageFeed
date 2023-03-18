//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 17.12.2022.
//

import UIKit

public protocol ImagesListViewControllerProtocol: AnyObject {
    func didUpdatePhotosAnimated(photosCount: Int)
    func didRecieve(alert: UIAlertController)
    func reloadRows(at: IndexPath)
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    @IBOutlet private(set) weak var tableView: UITableView!
    
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
    func didUpdatePhotosAnimated(photosCount: Int) {
        tableView.performBatchUpdates { [weak self] in
            let batchAmount = 10
            let photosIndexPaths = (photosCount - batchAmount..<photosCount).map { row in
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
        presenter?.setCellLoadingStateIfItsImageNil(cell)
        presenter?.requestFetchPhotosNextPageIfLastCell(at: indexPath)
    }
}

//MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photos.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        let imagesListCell = configured(cell: cell, at: indexPath) ?? UITableViewCell()
        return imagesListCell
    }
    
    func reloadRows(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    private func configured(cell: UITableViewCell, at indexPath: IndexPath) -> ImagesListCell? {
        guard let imagesListCell = cell as? ImagesListCell else {
            assertionFailure("Something went wrong in \(ImagesListCell.reuseIdentifier)")
            return nil
        }
        let configuredImagesListCell = presenter?.configured(cell: imagesListCell, at: indexPath)
        configuredImagesListCell?.delegate = self
        return configuredImagesListCell
    }
}
