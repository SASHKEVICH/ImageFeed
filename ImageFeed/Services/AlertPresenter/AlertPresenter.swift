//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 08.02.2023.
//

import UIKit

struct AlertPresenter: AlertPresenterProtocol {
    weak var delegate: AlertPresenterDelegate?
    
    func requestAlert(_ alertModel: AlertModel) {
        guard let delegate = delegate else { return }
        let alertController = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        guard let titles = alertModel.actionTitles else {
            delegate.didRecieve(alert: alertController)
            return
        }
        
        for (index, title) in titles.enumerated() {
            let handler = alertModel.completions?[safe: index]
            let action = UIAlertAction(title: title, style: .default, handler: handler)
            alertController.addAction(action)
        }
        delegate.didRecieve(alert: alertController)
    }
}
