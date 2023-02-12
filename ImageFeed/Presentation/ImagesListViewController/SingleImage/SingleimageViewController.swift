//
//  SingleimageViewController.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 30.12.2022.
//

import UIKit

final class SingleimageViewController: UIViewController {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        imageView.image = image
        
        rescale(image: image)
        centerContent()
        
        setupShareButton()
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    private func rescale(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        
        view.layoutIfNeeded()
        let viewRect = scrollView.bounds.size
        let scaleFactor = max(viewRect.width / image.size.width, viewRect.height / image.size.height)
        let scale = min(maxZoomScale, max(minZoomScale, scaleFactor))
        
        scrollView.setZoomScale(scale, animated: true)
        scrollView.layoutIfNeeded()
    }
    
    private func centerContent() {
        let newContentSize = scrollView.contentSize
        let visibleRectSize = scrollView.bounds.size
        
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func setupShareButton() {
        shareButton.layer.cornerRadius = shareButton.frame.size.height / 2
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
    }
    
    @objc private func didTapShareButton() {
        let activityItems = [image]
        let vc = UIActivityViewController(
            activityItems: activityItems as [Any],
            applicationActivities: nil
        )
        present(vc, animated: true)
    }
}

extension SingleimageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
