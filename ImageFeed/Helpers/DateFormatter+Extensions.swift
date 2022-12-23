//
//  DateFormatter+Extensions.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 22.12.2022.
//

import Foundation

extension DateFormatter {
    static let imagesListCellDateFormmater: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .none
        return df
    }()
}
