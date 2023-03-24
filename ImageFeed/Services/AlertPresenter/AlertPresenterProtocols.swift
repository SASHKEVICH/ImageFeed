//
//  AlertPresenterDelegate.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 01.03.2023.
//

import UIKit

public protocol AlertPresenterDelegate: AnyObject {
    func didRecieve(alert: UIAlertController)
}

protocol AlertPresenterProtocol {
    var delegate: AlertPresenterDelegate? { get set }
    func requestAlert(_ alertModel: AlertModel)
}
