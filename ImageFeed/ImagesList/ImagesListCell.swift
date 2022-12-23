//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 22.12.2022.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    @IBOutlet private var gradientView: UIView!
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    static let reuseIdentifier = "ImagesListCell"
    
    var isLiked: Bool = false {
        didSet {
            setButtonImage()
        }
    }
    
    var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .axial
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = CGRect.zero
        return gradientLayer
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellImage.layer.cornerRadius = 16
        cellImage.layer.masksToBounds = true
        
        likeButton.addTarget(self, action: #selector(handleLikeButtonTap), for: .touchUpInside)
        
        gradientLayer.frame = gradientView.bounds
        gradientView.layer.addSublayer(gradientLayer)
        gradientView.layer.cornerRadius = 16
        gradientView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradientView.layer.masksToBounds = true
    }
    
    @objc func handleLikeButtonTap() {
        isLiked.toggle()
        setButtonImage()
    }
    
    private func setButtonImage() {
        likeButton.setImage(UIImage(named: isLiked ? "like_button_on" : "like_button_off"), for: .normal)
    }
}
