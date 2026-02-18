//
//  TimeProvider.swift
//  Logora
//
//  Created by Mostafa Muhammad on 22/01/2026.
//


import Foundation

enum TimeProvider {

    static func elapsedMs(since date: Date) -> Int {
        Int(Date().timeIntervalSince(date) * 1000)
    }

    static func isoString(from date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }
}
