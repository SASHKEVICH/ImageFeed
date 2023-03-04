//
//  URLSessionTask+IsStillRunning.swift
//  ImageFeed
//
//  Created by Александр Бекренев on 20.02.2023.
//

import Foundation

extension URLSessionTask? {
    var isStillRunning: Bool {
        self != nil
    }
}
