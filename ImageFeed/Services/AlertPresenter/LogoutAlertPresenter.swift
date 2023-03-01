//
//  LogoutAlertPresenter.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 01.03.2023.
//

import UIKit

struct LogoutAlertPresenter {
    
    weak var delegate: AlertPresenterDelegate?
    
    func requestAlert(logoutCompletion: @escaping (UIAlertAction) -> Void) {
        guard let delegate = delegate else { return }
        let alertController = UIAlertController(
            title: "Пока-пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        let yesAction = UIAlertAction(title: "Да", style: .default, handler: logoutCompletion)
        let noAction = UIAlertAction(title: "Нет", style: .cancel) { _ in }
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        delegate.didRecieveAlert(alertController)
    }
    
}
