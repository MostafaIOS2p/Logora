//
//  BodyFormatter.swift
//  Logora
//
//  Created by Mostafa Muhammad on 22/01/2026.
//


import Foundation

enum BodyFormatter {

    static func formatBody(
        data: Data?,
        contentType: String?,
        config: LoggerConfig
    ) -> String? {

        guard config.includeBodies else { return nil }
        guard let data, !data.isEmpty else { return nil }

        // Size limit
        let limited = data.prefix(config.maxBodyBytes)
        guard !limited.isEmpty else { return nil }

        // Binary detection
        if isBinary(contentType: contentType, data: limited) {
            return "<binary \(data.count) bytes>"
        }

        // Try JSON redaction
        if let obj = try? JSONSerialization.jsonObject(with: limited, options: []),
           let redacted = Masking.redactJSON(obj, keysToRedact: config.redactedBodyKeys),
           let outData = try? JSONSerialization.data(withJSONObject: redacted, options: [.fragmentsAllowed]),
           let outStr = String(data: outData, encoding: .utf8) {
            return outStr
        }

        // Fallback to string
        // If it’s text-ish but not JSON
        if let str = String(data: limited, encoding: .utf8) {
            return str
        }

        // If utf8 fails, treat as binary
        return "<binary \(data.count) bytes>"
    }

    private static func isBinary(contentType: String?, data: Data) -> Bool {
        // Strong signal from content-type
        if let ct = contentType?.lowercased() {
            if ct.hasPrefix("image/")
                || ct.hasPrefix("video/")
                || ct.hasPrefix("audio/")
                || ct.contains("application/octet-stream")
                || ct.contains("multipart/form-data")
                || ct.contains("application/zip")
                || ct.contains("application/pdf")
                || ct.contains("application/x-protobuf")
            {
                return true
            }
        }

        // Heuristic: lots of zero bytes or non-printable ratio
        // (simple & fast)
        let bytes = [UInt8](data)
        if bytes.contains(0) { return true }

        var nonPrintable = 0
        for b in bytes.prefix(1024) { // sample first 1KB
            // allow tabs/newlines and printable ASCII
            let isPrintable = (b == 9 || b == 10 || b == 13 || (b >= 32 && b <= 126))
            if !isPrintable { nonPrintable += 1 }
        }
        let sampleCount = min(bytes.count, 1024)
        if sampleCount > 0 {
            let ratio = Double(nonPrintable) / Double(sampleCount)
            return ratio > 0.30
        }
        return false
    }
}
