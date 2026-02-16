//
//  NetworkLogTracker.swift
//  PrettyLogs
//
//  Created by Mostafa Muhammad on 22/01/2026.
//


import Foundation

final class NetworkLogTracker {
    let start: Date
    let request: URLRequest

    var response: HTTPURLResponse?
    var responseData: Data?
    var error: Error?

    init(request: URLRequest, start: Date = Date()) {
        self.request = request
        self.start = start
    }
}
