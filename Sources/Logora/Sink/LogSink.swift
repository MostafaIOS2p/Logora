//
//  LogSink.swift
//  Logora
//
//  Created by Mostafa M444uhammad on 22/01/2026.
//


import Foundation

public protocol LogSink {
    func handle(_ log: NetworkLog)
    func handleRealtime(_ logs: [RealtimeLog])
}
/// Default sink for v1
public final class ConsoleLogSink: LogSink {

    public init() {}

    public func handle(_ log: NetworkLog) {

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📡 [NetworkLog]")
        print("➡️ \(log.method) \(log.url)")
        print("⏱ duration: \(log.durationMs) ms")
        print("📥 status: \(log.statusCode.map(String.init) ?? "nil")")

        if let headers = log.requestHeaders, !headers.isEmpty {
            print("📤 Request Headers:")
            headers.forEach { print("   \($0): \($1)") }
        }

        if let body = log.requestBody {
            print("📤 Request Body:")
            print(body)
        }

        if let headers = log.responseHeaders, !headers.isEmpty {
            print("📥 Response Headers:")
            headers.forEach { print("   \($0): \($1)") }
        }

        if let body = log.responseBody {
            print("📥 Response Body:")
            print(body)
        }

        if let error = log.error {
            print("❌ Error:")
            print(error)
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
}

/// Optional: store in-memory (useful for future debug screens or exporting)
public final class MemoryLogSink: LogSink {

    private var logs: [NetworkLog] = []

    public init() {}

    public func handle(_ log: NetworkLog) {
        logs.append(log)
    }

    public func allLogs() -> [NetworkLog] {
        logs
    }

    public func clear() {
        logs.removeAll()
    }
}
public extension LogSink {
    func handleRealtime(_ logs: [RealtimeLog]) {}
}
