//
//  LoadingGradientAnimationView.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 26.02.2023.
//

import UIKit

final class LoadingGradientAnimationView: UIView {

    convenience init(frame: CGRect, cornerRadius: CGFloat = 0) {
        self.init(frame: frame)
        
        let animation = setupGradientChangeAnimation()
        let gradient = setupGradient(frame: frame, cornerRadius: cornerRadius, animation: animation)
        layer.addSublayer(gradient)
    }
    
}

private extension LoadingGradientAnimationView {
    
    func setupGradientChangeAnimation() -> CABasicAnimation {
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.2
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        
        return gradientChangeAnimation
    }
    
    func setupGradient(frame: CGRect, cornerRadius: CGFloat, animation: CABasicAnimation) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.cornerRadius = cornerRadius
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.masksToBounds = true
        gradient.add(animation, forKey: "locationsChange")
        
        return gradient
    }
    
}
