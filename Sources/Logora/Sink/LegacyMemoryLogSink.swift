//
//  LegacyMemoryLogSink.swift
//  Logora
//
//  Created by Mostafa Muhammad on 22/01/2026.
//

import Foundation

public final class LegacyMemoryLogSink: LogSink {

    private let lock = NSLock()
    private var logs: [NetworkLog] = []

    public init() {}

    public func handle(_ log: NetworkLog) {
        lock.lock()
        logs.append(log)
        lock.unlock()
    }
}
