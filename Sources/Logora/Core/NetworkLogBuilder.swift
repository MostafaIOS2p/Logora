//
//  NetworkLogBuilder.swift
//  Logora
//
//  Created by Mostafa Muhammad on 22/01/2026.
//


import Foundation

enum NetworkLogBuilder {

    static func build(from tracker: NetworkLogTracker, config: LoggerConfig) -> NetworkLog {

        let durationMs = Int(Date().timeIntervalSince(tracker.start) * 1000.0)

        let method = tracker.request.httpMethod ?? "UNKNOWN"
        let url = tracker.request.url?.absoluteString ?? "UNKNOWN_URL"

        var reqHeaders = tracker.request.allHTTPHeaderFields
        reqHeaders = Masking.redactHeaders(reqHeaders, redacted: config.redactedHeaders)

        let reqContentType = tracker.request.value(forHTTPHeaderField: "Content-Type")

        let reqBody = BodyFormatter.formatBody(
            data: tracker.request.httpBody,
            contentType: reqContentType,
            config: config
        )

        let statusCode = tracker.response?.statusCode

        let resContentType = tracker.response?.value(forHTTPHeaderField: "Content-Type")

        var resHeaders: [String: String]? = nil
        if let all = tracker.response?.allHeaderFields {
            var casted: [String: String] = [:]
            for (k, v) in all {
                casted[String(describing: k)] = String(describing: v)
            }
            resHeaders = Masking.redactHeaders(casted, redacted: config.redactedHeaders)
        }

        let resBody = BodyFormatter.formatBody(
            data: tracker.responseData,
            contentType: resContentType,
            config: config
        )
        let metadata = LoggerState.shared.metadata

        let err = tracker.error.map { String(describing: $0) }

        return NetworkLog(
            durationMs: durationMs,
            method: method,
            url: url,
            requestHeaders: reqHeaders,
            requestBody: reqBody,
            statusCode: statusCode,
            responseHeaders: resHeaders,
            responseBody: resBody,
            error: err,
            appId: metadata?.appId ?? "",
            environment:metadata?.environment ?? "",
            device:metadata?.device ?? "",
            build:metadata?.build ?? ""

        )
    }
}

// MARK: - HTTP header helper

private extension HTTPURLResponse {
    func value(forHTTPHeaderField name: String) -> String? {
        for (k, v) in allHeaderFields {
            if String(describing: k).lowercased() == name.lowercased() {
                return String(describing: v)
            }
        }
        return nil
    }
}
