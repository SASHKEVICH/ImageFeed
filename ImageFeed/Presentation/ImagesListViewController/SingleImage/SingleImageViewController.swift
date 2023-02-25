//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 30.12.2022.
//

import UIKit

final class SingleImageViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var shareButton: UIButton!
    
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
        
        if let fullImageURL = fullImageURL {
            setImage(with: fullImageURL)
        }
        
        setupShareButton()
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
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

private extension SingleImageViewController {
    
    func setImage(with url: URL) {
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.rescale(image: imageResult.image)
                self.centerContent()
            case .failure:
                print("error")
                // TODO: self.showError()
            }
        }
    }
    
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
    
}

extension SingleImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
}
