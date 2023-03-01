//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 08.02.2023.
//

import UIKit

struct AuthAlertPresenter {
    
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
