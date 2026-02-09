//
//  HttpLogger.swift
//  PrettyLogs
//
//  Created by Mostafa Muhammad on 01/02/2026.
//


// HttpLogger.swift
// PrettyLogs

import Foundation

final class HttpLogger {

    private let state: LoggerState

    init(state: LoggerState) {
        self.state = state
    }

    func log(_ log: NetworkLog) {
        guard state.config.mode == .enabled else { return }
        state.sink.handle(log)
    }
}