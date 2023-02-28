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
    
    enum FeedCellImageState {
        case loading
        case error
        case finished(UIImage)
    }
    
    @IBOutlet private var gradientView: UIView!
    @IBOutlet var cellImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    weak var delegate: ImagesListCellDelegate?
    
    static let reuseIdentifier = "ImagesListCell"
    
    var cellState: FeedCellImageState? {
        didSet {
            switch cellState {
            case .loading:
                startLoadingAnimation()
            case .error:
                stopLoadingAnimation()
                cellImageView.image = UIImage(named: "card_photo_stub")
            case .finished(let image):
                stopLoadingAnimation()
                cellImageView.image = image
            default:
                break
            }
        }
    }
    
    var isLiked: Bool = false {
        didSet {
            setButtonLikedOrDisliked()
        }
    }
    
    private var loadingAnimationView: LoadingGradientAnimationView?
    private var loadingAnimationLayer: CAGradientLayer?
    
    private var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .axial
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.0), UIColor.black.withAlphaComponent(0.2).cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = CGRect.zero
        return gradientLayer
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellImageView.layer.cornerRadius = 16
        cellImageView.layer.masksToBounds = true
        
        likeButton.addTarget(self, action: #selector(handleLikeButtonTap), for: .touchUpInside)
        
        gradientLayer.frame = gradientView.bounds
        gradientView.layer.addSublayer(gradientLayer)
        gradientView.layer.cornerRadius = 16
        gradientView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradientView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopLoadingAnimation()
        cellImageView.kf.cancelDownloadTask()
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

extension ImagesListCell {
    
    func startLoadingAnimation() {
        loadingAnimationView = LoadingGradientAnimationView(frame: cellImageView.bounds)
        guard let loadingAnimationView = loadingAnimationView else { return }
        cellImageView.addSubview(loadingAnimationView)
//        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
//        gradientChangeAnimation.duration = 1.2
//        gradientChangeAnimation.repeatCount = .infinity
//        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
//        gradientChangeAnimation.toValue = [0, 0.8, 1]
//
//        loadingAnimationLayer = CAGradientLayer()
//        guard let gradient = loadingAnimationLayer else { return }
//        gradient.frame = bounds
//        gradient.cornerRadius = 0
//        gradient.locations = [0, 0.1, 0.3]
//        gradient.colors = [
//            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
//            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
//            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
//        ]
//        gradient.startPoint = CGPoint(x: 0, y: 0.5)
//        gradient.endPoint = CGPoint(x: 1, y: 0.5)
//        gradient.masksToBounds = true
//        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
//
//        cellImageView.layer.addSublayer(gradient)
    }
    
    func stopLoadingAnimation() {
        loadingAnimationView?.removeFromSuperview()
        loadingAnimationView = nil
//        loadingAnimationLayer?.removeFromSuperlayer()
//        loadingAnimationLayer = nil
    }
    
}
