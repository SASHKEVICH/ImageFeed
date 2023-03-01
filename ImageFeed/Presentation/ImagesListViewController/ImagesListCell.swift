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
                showLoadingAnimation()
            case .error:
                hideLoadingAnimation()
                cellImageView.image = UIImage(named: "card_photo_stub")
            case .finished(let image):
                hideLoadingAnimation()
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
        hideLoadingAnimation()
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
    
    func showLoadingAnimation() {
        let loadingView = LoadingGradientAnimationView(frame: bounds, cornerRadius: 0)
        loadingAnimationView = loadingView
        cellImageView.addSubview(loadingView)
    }
    
    func hideLoadingAnimation() {
        loadingAnimationView?.removeFromSuperview()
        loadingAnimationView = nil
    }
    
}
