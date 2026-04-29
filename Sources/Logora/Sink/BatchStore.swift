//
//  BatchStore.swift
//  Logora
//
//  Created by Mostafa Muhammad on 22/01/2026.
//


import Foundation

final class BatchStore<T>: @unchecked Sendable {
    private var items: [T] = []
    private let lock = NSLock()

    func append(_ item: T) {
        lock.lock()
        items.append(item)
        lock.unlock()
    }

    func append(contentsOf newItems: [T]) {
        lock.lock()
        items.append(contentsOf: newItems)
        lock.unlock()
    }

    func drain(max: Int) -> [T] {
        lock.lock()
        defer { lock.unlock() }

        guard !items.isEmpty else { return [] }

        let count = Swift.min(max, items.count)
        let out = Array(items.prefix(count))
        items.removeFirst(count)
        return out
    }

    var isEmpty: Bool {
        lock.lock()
        defer { lock.unlock() }
        return items.isEmpty
    }
}
