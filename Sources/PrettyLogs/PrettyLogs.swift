// The Swift Programming Language
// https://docs.swift.org/swift-book
// PrettyLogs.swift (public API)
import Foundation

public enum PrettyLogs {

    public static func start(
        mode: LoggerConfig.Mode = .enabled,
        apiKey: String,
        loggerType: LoggerConfig.LoggeerType = .http,
        environment: String
    ) {
        Task { @MainActor in
            let metadata = DefaultLoggerMetadata.make(environment: environment)

            let config = LoggerConfig(
                mode: mode,
                loggeerType: loggerType,
                ingestionURL: PrettyLogsEndpoints.httpLink,
                realtimeEndpoint: PrettyLogsEndpoints.realtime,
                apiKey: apiKey
            )

            let sink: LogSink
            if loggerType == .realtime {
                sink = HTTPLogSink(
                    endpoint: PrettyLogsEndpoints.realtime,
                    apiKey: apiKey
                )
            } else {
                sink = ConsoleLogSink()
            }

            LoggerState.shared.configure(
                config: config,
                sink: sink,
                metadata: metadata
            )
        }
    }
}

public extension PrettyLogs {

    static let realtime = Realtime()
    
    struct Realtime: Sendable {

        public func log(
            transport: RealtimeLog.Transport,
            direction: RealtimeLog.Direction,
            event: String,
            payload: Any? = nil,
            error: String? = nil
        ) {
            // ✅ Convert BEFORE crossing concurrency boundary
            let payloadString = PayloadStringifier.stringify(payload)

            Task {
                await InternalLoggerContainer.shared.logRealtime(
                    transport: transport,
                    direction: direction,
                    event: event,
                    payload: payloadString,
                    error: error
                )
            }
        }
    }
}
