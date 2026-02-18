//
//  PayloadStringifier.swift
//  Logora
//
//  Created by Mostafa Muhammad on 01/02/2026.
//


import Foundation

enum PayloadStringifier {

    static func stringify(_ payload: Any?) -> String? {
        guard let payload else { return nil }

        if let s = payload as? String {
            return s
        }

        if JSONSerialization.isValidJSONObject(payload),
           let data = try? JSONSerialization.data(
                withJSONObject: payload,
                options: [.prettyPrinted]
           ),
           let str = String(data: data, encoding: .utf8) {
            return str
        }

        return String(describing: payload)
    }
}
