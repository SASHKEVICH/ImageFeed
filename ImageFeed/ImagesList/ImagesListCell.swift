//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 22.12.2022.
//

import UIKit

class ImagesListCell: UITableViewCell {
    @IBOutlet private var bottomGradientView: UIView!
    @IBOutlet private var cellImage: UIImageView!
    
    static let reuseIdentifier = "ImagesListCell"
    
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
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        gradientLayer.frame = bottomGradientView.bounds
        bottomGradientView.layer.addSublayer(gradientLayer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
