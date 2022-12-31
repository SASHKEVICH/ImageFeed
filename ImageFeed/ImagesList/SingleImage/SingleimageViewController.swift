//
//  SingleimageViewController.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 30.12.2022.
//

import UIKit

class SingleimageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        rescale(image: image)
        centerContent()
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    private func rescale(image: UIImage) {
        let imageDimensions = (image.size.width, image.size.height)
        let viewDimensions = (view.bounds.size.width, view.bounds.size.height)
        
        let scaleFactor = max(viewDimensions.0 / imageDimensions.0, viewDimensions.1 / imageDimensions.1)
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        
        let scale = min(maxZoomScale, min(minZoomScale, scaleFactor))
        let rescaledImageSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        
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
}

extension SingleimageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
