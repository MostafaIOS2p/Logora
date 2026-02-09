//
//  BatchStore.swift
//  PrettyLogs
//
//  Created by Mostafa Muhammad on 22/01/2026.
//


import Foundation

final class BatchStore<T> {
    private var items: [T] = []
    private let lock = NSLock()

    func append(_ item: T) {
        lock.lock(); defer { lock.unlock() }
        items.append(item)
    }

    func drain(max: Int? = nil) -> [T] {
        lock.lock(); defer { lock.unlock() }
        if let max, items.count > max {
            let out = Array(items.prefix(max))
            items.removeFirst(out.count)
            return out
        } else {
            let out = items
            items.removeAll(keepingCapacity: true)
            return out
        }
    }

    var count: Int {
        lock.lock(); defer { lock.unlock() }
        return items.count
    }
}