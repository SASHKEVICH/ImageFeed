//
//  Date+ImagesListCellDateString.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 03.03.2023.
//

import Foundation

extension Date? {
    func imagesListCellDateString() -> String {
        switch self {
        case .some(let date):
            return DateFormatter.imagesListCellDateFormmater.string(from: date)
        case .none:
            return ""
        }
    }
}
