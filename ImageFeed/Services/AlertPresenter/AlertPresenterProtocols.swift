//
//  AlertPresenterDelegate.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 01.03.2023.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func didRecieveAlert(_ vc: UIAlertController)
}

protocol AlertPresenterProtocol {
    func requestAlert(_ alertModel: AlertModel)
}
