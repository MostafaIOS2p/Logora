//
//  RealtimeLogger.swift
//  Logora
//
//  Created by Mostafa Muhammad on 28/01/2026.
//


import Foundation
// RealtimeLogger.swift

final class RealtimeLogger {

    private let state: LoggerState

    init(state: LoggerState) {
        self.state = state
    }

    func log(
        transport: RealtimeLog.Transport,
        direction: RealtimeLog.Direction,
        event: String,
        payload: String?,
        error: String? = nil
    ) {
        let config = state.config
        guard config.mode == .enabled else { return }
        guard config.realtimeEndpoint != nil else { return }

        let log = RealtimeLog(
            transport: transport,
            direction: direction,
            event: event,
            payload: payload,
            error: error,
            appId: state.metadata?.appId,
            environment: state.metadata?.environment,
            device: state.metadata?.device,
            build: state.metadata?.build
        )

        state.sink.handleRealtime([log])
    }
}
