//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 30.12.2022.
//

import UIKit
import Kingfisher
import ProgressHUD

final class SingleImageViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var shareButton: UIButton!
    
    private var alertPresenter: AlertPresenterProtocol?
    
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
            rescale(image: image)
            centerContent()
        }
    }
    
    var fullImageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        imageView.image = image
        
        self.alertPresenter = AlertPresenter(delegate: self)
        
        if let fullImageURL = fullImageURL {
            startFullImageDownloading(with: fullImageURL)
        }
        
        setupShareButton()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction
    private func didTapBackButton() {
        dismissViewController()
    }
    
    @objc
    private func didTapShareButton() {
        let activityItems = [image]
        let vc = UIActivityViewController(
            activityItems: activityItems as [Any],
            applicationActivities: nil
        )
        present(vc, animated: true)
    }
    
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

private extension SingleImageViewController {
    
    func rescale(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        
        view.layoutIfNeeded()
        let viewRect = scrollView.bounds.size
        let scaleFactor = max(viewRect.width / image.size.width, viewRect.height / image.size.height)
        let scale = min(maxZoomScale, max(minZoomScale, scaleFactor))
        
        scrollView.setZoomScale(scale, animated: true)
        scrollView.layoutIfNeeded()
    }
    
    func centerContent() {
        let newContentSize = scrollView.contentSize
        let visibleRectSize = scrollView.bounds.size
        
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    func setupShareButton() {
        shareButton.layer.cornerRadius = shareButton.frame.size.height / 2
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
    }
    
    func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    func startFullImageDownloading(with url: URL) {
        ProgressHUD.show()
        disableShareButton()
        downloadAndSetImage(with: url)
    }
    
}

private extension SingleImageViewController {
    
    func disableShareButton() {
        shareButton.isEnabled = false
    }
    
    func enableShareButton() {
        shareButton.isEnabled = true
    }
    
}

extension SingleImageViewController: AlertPresenterDelegate {
    func didRecieveAlert(_ vc: UIAlertController) {
        present(vc, animated: true)
    }
}

private extension SingleImageViewController {
    
    func downloadAndSetImage(with url: URL) {
        ImageDownloader.default.downloadImage(with: url) { [weak self] result in
            guard let self = self else { return }
            ProgressHUD.dismiss()
            self.enableShareButton()
            switch result {
            case .success(let imageResult):
                let image = imageResult.image
                self.set(image: image)
            case .failure(let error):
                let dismissHandler: (UIAlertAction) -> Void = { [weak self] _ in
                    self?.dismissViewController()
                }
                let alertModel = AlertModel(
                    title: "Ошибка сети(",
                    message: "Не удалось загрузить картинку",
                    actionTitles: ["OK"],
                    completions: [dismissHandler])
                self.alertPresenter?.requestAlert(alertModel)
                print(error)
            }
        }
    }
    
    func set(image: UIImage) {
        imageView.image = image
        rescale(image: image)
        self.image = image
        centerContent()
    }
    
}
