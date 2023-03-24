//
//  ProfileAlertHelper.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 16.03.2023.
//

import UIKit

protocol ProfileAlertHelperProtocol {
    func exitButtonAlertModel(logoutHandler: @escaping () -> Void) -> AlertModel
    func profileIsEmptyAlertModel() -> AlertModel
    func imageDownloadingFailureAlertModel() -> AlertModel
}

struct ProfileAlertHelper: ProfileAlertHelperProtocol {
    func exitButtonAlertModel(
        logoutHandler: @escaping () -> Void
    ) -> AlertModel {
        let completion: (UIAlertAction) -> Void = { _ in logoutHandler() }
        let alertModel = AlertModel(
            title: "Пока-пока!",
            message: "Уверены, что хотите выйти?",
            actionTitles: ["Да", "Нет"],
            completions: [completion])
        return alertModel
    }
    
    func profileIsEmptyAlertModel() -> AlertModel {
        let alertModel = AlertModel(
            title: "Ошибка загрузки",
            message: "Не удалось загрузить информацию профиля(",
            actionTitles: ["OK"])
        return alertModel
    }
    
    func imageDownloadingFailureAlertModel() -> AlertModel {
        let alertModel = AlertModel(
            title: "Ошибка загрузки",
            message: "Не удалось загрузить аватар профиля(",
            actionTitles: ["OK"])
        return alertModel
    }
}
