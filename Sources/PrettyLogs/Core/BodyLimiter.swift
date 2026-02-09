//
//  BodyLimiter.swift
//  PrettyLogs
//
//  Created by Mostafa Muhammad on 22/01/2026.
//


import Foundation

enum BodyLimiter {

    static func bodyString(
        _ data: Data?,
        config: LoggerConfig
    ) -> String? {

        guard config.includeBodies else { return nil }
        guard let data, !data.isEmpty else { return nil }

        let limited = data.prefix(config.maxBodyBytes)
        guard !limited.isEmpty else { return nil }

        // Try JSON masking
        if let obj = try? JSONSerialization.jsonObject(with: limited),
           let redacted = Masking.redactJSON(obj, keysToRedact: config.redactedBodyKeys),
           let out = try? JSONSerialization.data(withJSONObject: redacted),
           let str = String(data: out, encoding: .utf8) {
            return str
        }

        return String(data: limited, encoding: .utf8)
    }
}