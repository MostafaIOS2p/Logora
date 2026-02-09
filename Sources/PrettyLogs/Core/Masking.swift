//
//  Masking.swift
//  PrettyLogs
//
//  Created by Mostafa Muhammad on 22/01/2026.
//


import Foundation

enum Masking {

    static func redactHeaders(_ headers: [String: String]?, redacted: Set<String>) -> [String: String]? {
        guard var headers else { return nil }
        for key in headers.keys {
            if redacted.contains(key.lowercased()) {
                headers[key] = "****"
            }
        }
        return headers
    }

    // ✅ Make this internal to Core but accessible within module
    static func redactJSON(_ obj: Any, keysToRedact: Set<String>) -> Any? {
        if var dict = obj as? [String: Any] {
            for (k, v) in dict {
                if keysToRedact.contains(k.lowercased()) {
                    dict[k] = "****"
                } else if let nested = redactJSON(v, keysToRedact: keysToRedact) {
                    dict[k] = nested
                }
            }
            return dict
        }

        if var arr = obj as? [Any] {
            for i in arr.indices {
                if let nested = redactJSON(arr[i], keysToRedact: keysToRedact) {
                    arr[i] = nested
                }
            }
            return arr
        }

        return obj
    }
}
