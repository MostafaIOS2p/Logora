//
//  LoggerConfig.swift
//  PrettyLogs
//
//  Created by Mostafa Muhammad on 22/01/2026.
//


import Foundation

public struct LoggerConfig: Sendable {

    public enum Mode: Sendable { case disabled, enabled }
    public enum LoggeerType: Sendable { case http, realtime ,none}

    public let mode: Mode
    public let loggeerType: LoggeerType

    // Bodies
    public let includeBodies: Bool
    public let maxBodyBytes: Int
    
    // Redaction
    public let redactedHeaders: Set<String>
    public let redactedBodyKeys: Set<String>

    // Endpoint filtering (NEW)
    /// If non-empty => ONLY log if URL matches at least one allow rule.
    public let allowList: [EndpointRule]
    /// If matches any deny rule => DO NOT log.
    public let denyList: [EndpointRule]

    // Transport config (optional for HTTPLogSink)
    public let ingestionURL: URL?
    public let realtimeEndpoint: URL?
    public let apiKey: String?

    public init(
        mode: Mode,
        loggeerType: LoggeerType,
        includeBodies: Bool = true,
        maxBodyBytes: Int = 32_000,
        redactedHeaders: Set<String> = ["authorization", "cookie", "set-cookie"],
        redactedBodyKeys: Set<String> = ["password", "token", "access_token", "refresh_token", "secret"],
        allowList: [EndpointRule] = [],
        denyList: [EndpointRule] = [],
        ingestionURL: URL? = nil,
        realtimeEndpoint: URL? = nil,
        apiKey: String? = nil
    ) {
        self.mode = mode
        self.loggeerType = loggeerType
        self.includeBodies = includeBodies
        self.maxBodyBytes = maxBodyBytes
        self.redactedHeaders = Set(redactedHeaders.map { $0.lowercased() })
        self.redactedBodyKeys = Set(redactedBodyKeys.map { $0.lowercased() })
        self.allowList = allowList
        self.denyList = denyList
        self.ingestionURL = ingestionURL
        self.apiKey = apiKey
        self.realtimeEndpoint = realtimeEndpoint
    }

    public static let disabled = LoggerConfig(mode: .disabled, loggeerType: .none, includeBodies: false)
}

// MARK: - Endpoint rules

                                                                                                                                                                                                                                                                                                                                                                                                                                                                public struct EndpointRule: Sendable {
    public enum Field: Sendable { case fullURL, host, path }

    public let field: Field
    public let match: Match

    public init(field: Field, match: Match) {
        self.field = field
        self.match = match
    }

    public enum Match: Sendable {
        case equals(String)
        case contains(String)
        case hasPrefix(String)
    }

                                                                                                                                                                                                                                                                                                                                                                                                    public func matches(url: URL) -> Bool {
                                                                                                                                                                                                                                                                                                                                                                                                                                                                    let value: String
        switch field {
        case .fullURL: value = url.absoluteString
        case .host: value = url.host ?? ""
        case .path: value = url.path
        }

        switch match {
        case .equals(let s): return value == s
        case .contains(let s): return value.contains(s)
        case .hasPrefix(let s): return value.hasPrefix(s)
        }
    }
}

// MARK: - Filtering helper

extension LoggerConfig {

    func shouldLog(request: URLRequest) -> Bool {
        guard mode == .enabled else { return false }
        guard let url = request.url else { return false }

        // 🚫 Block ingestion endpoints to prevent recursion
        if let ingestionURL,
           url.host == ingestionURL.host,
           (url.path == "/v1/logs" || url.path == "/v1/realtime-logs") {
            return false
        }

        // 🚫 Deny list
        if denyList.contains(where: { $0.matches(url: url) }) {
            return false
        }

        // ✅ Allow list
        if !allowList.isEmpty {
            return allowList.contains(where: { $0.matches(url: url) })
        }

        return true
    }
}

