//
//  Date+ImagesListCellDateString.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 03.03.2023.
//

import Foundation

extension Date? {
    func imagesListCellDateString() -> String {
        var dateString = ""
        if let date = self {
            dateString = DateFormatter.imagesListCellDateFormmater.string(from: date)
        }
        return dateString
        
    }
}
