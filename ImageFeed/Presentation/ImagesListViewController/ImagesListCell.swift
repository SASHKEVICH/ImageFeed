//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 22.12.2022.
//

import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    @IBOutlet private var gradientView: UIView!
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    weak var delegate: ImagesListCellDelegate?
    
    static let reuseIdentifier = "ImagesListCell"
    
    var isLiked: Bool = false {
        didSet {
            setButtonLikedOrDisliked()
        }
    }
    
    var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .axial
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.0), UIColor.black.withAlphaComponent(0.2).cgColor]
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    override func layoutSubviews() {
        gradientLayer.frame = gradientView.bounds
        super.layoutSubviews()
    }
    
    @objc
    func handleLikeButtonTap() {
        isLiked.toggle()
        setButtonLikedOrDisliked()
        delegate?.imagesListCellDidTapLike(self)
    }
    
    private func setButtonLikedOrDisliked() {
        likeButton.setImage(UIImage(named: isLiked ? "like_button_on" : "like_button_off"), for: .normal)
    }
}
