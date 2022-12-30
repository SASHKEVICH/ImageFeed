//
//  SingleimageViewController.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 30.12.2022.
//

import UIKit

class SingleimageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
}
