//
//  InternalLoggerContainer.swift
//  PrettyLogs
//
//  Created by Mostafa Muhammad on 01/02/2026.
//
// InternalLoggerContainer.swift
// PrettyLogs

import Foundation

actor InternalLoggerContainer {

    static let shared = InternalLoggerContainer()

    private var realtimeLogger: RealtimeLogger?
    private var httpLogger: HttpLogger?

    private init() {}

    func configure(state: LoggerState) {

        // Realtime logger
        if state.config.realtimeEndpoint != nil {
            realtimeLogger = RealtimeLogger(state: state)
        } else {
            realtimeLogger = nil
        }

        // HTTP logger
        if state.config.ingestionURL != nil {
            httpLogger = HttpLogger(state: state)
        } else {
            httpLogger = nil
        }
    }

    func logRealtime(
        transport: RealtimeLog.Transport,
        direction: RealtimeLog.Direction,
        event: String,
        payload: String?,
        error: String?
    ) {
        realtimeLogger?.log(
            transport: transport,
            direction: direction,
            event: event,
            payload: payload,
            error: error
        )
    }

    func logHttp(_ log: NetworkLog) {
        httpLogger?.log(log)
    }
}
