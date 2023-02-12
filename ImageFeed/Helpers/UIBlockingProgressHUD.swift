//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 06.02.2023.
//

import UIKit
import ProgressHUD

struct UIBlockingProgressHUD {
    
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.show()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
    
}
