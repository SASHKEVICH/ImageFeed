//
//  AlertModel.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 03.03.2023.
//

import UIKit

struct AlertModel {
    let title: String?
    let message: String?
    var actionTitles: [String]? = nil
    var completions: [(UIAlertAction) -> Void]? = nil
}
