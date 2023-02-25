//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 08.02.2023.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func didRecieveAlert(_ vc: UIAlertController)
}

protocol AlertPresenterProtocol {
    func requestAlert()
}

struct AuthAlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    func requestAlert() {
        guard let delegate = delegate else { return }
        let alertController = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "OK", style: .default) { _ in }
        alertController.addAction(action)
        delegate.didRecieveAlert(alertController)
    }
    
}