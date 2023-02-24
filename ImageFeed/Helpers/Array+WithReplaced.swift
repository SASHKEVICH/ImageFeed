//
//  Array+WithReplaced.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 24.02.2023.
//

import Foundation

extension Array {
    func withReplaced(itemAt: Int, newValue: Element) -> [Element] {
        var newArray = self
        newArray[itemAt] = newValue
        return newArray
    }
}
