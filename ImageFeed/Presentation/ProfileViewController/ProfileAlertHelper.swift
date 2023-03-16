//
//  ProfileAlertHelper.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 16.03.2023.
//

import UIKit

public protocol ProfileAlertHelperProtocol {
    func exitButtonAlertModel(logoutHandler: @escaping (UIAlertAction) -> Void) -> AlertModel
    func profileIsEmptyAlertModel() -> AlertModel
    func imageDownloadingFailureAlertModel() -> AlertModel
}

struct ProfileAlertHelper: ProfileAlertHelperProtocol {
    func exitButtonAlertModel(logoutHandler: @escaping (UIAlertAction) -> Void) -> AlertModel {
        let alertModel = AlertModel(
            title: "Пока-пока!",
            message: "Уверены, что хотите выйти?",
            actionTitles: ["Да", "Нет"],
            completions: [logoutHandler])
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
