//
//  LoggerState.swift
//  PrettyLogs
//
//  Created by Mostafa Muhammad on 22/01/2026.
//


import Foundation

public final class LoggerState: @unchecked Sendable {

    public static let shared = LoggerState()

    private let lock = NSLock()

    private var _config: LoggerConfig = .disabled
    private var _sink: LogSink = ConsoleLogSink()
    private var _metadata: LoggerMetadata?

    var config: LoggerConfig { locked { _config } }
    var sink: LogSink { locked { _sink } }
    var metadata: LoggerMetadata? { locked { _metadata } }

    func configure(
        config: LoggerConfig,
        sink: LogSink,
        metadata: LoggerMetadata
    ) {
        lock.lock()
        _config = config
        _sink = sink
        _metadata = metadata
        lock.unlock()

        // 🔥 Bridge into actor safely
        Task {
            await InternalLoggerContainer.shared.configure(state: self)
        }
    }

    private func locked<T>(_ block: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return block()
    }

    private init() {}
}
