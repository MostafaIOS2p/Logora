//
//  HTTPLogSink.swift
//  Logora
//
//  Created by Mostafa Muhammad on 22/01/2026.
//


import Foundation

#if canImport(UIKit)
import UIKit
#endif

public final class HTTPLogSink: LogSink, @unchecked Sendable {

    private let baseURL: URL
    private let apiKey: String
    private let session: URLSession

    private let networkStore = BatchStore<NetworkLog>()
    private let realtimeStore = BatchStore<RealtimeLog>()

    private let queue = DispatchQueue(label: "Logora.HTTPLogSink.queue")
    private var timer: DispatchSourceTimer?

    private let batchSize = 20
    private let flushInterval: TimeInterval = 3
    private let maxRetries = 3

    public init(endpoint: URL, apiKey: String) {
        self.baseURL = Self.normalizedBaseURL(from: endpoint)
        self.apiKey = apiKey

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [] // prevent logging our own Logora requests
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 30

        self.session = URLSession(configuration: config)

        startTimer()
        observeAppLifecycle()
    }

    deinit {
        timer?.cancel()
    }

    public func handle(_ log: NetworkLog) {
        networkStore.append(log)
        flushIfNeeded()
    }

    public func handleRealtime(_ logs: [RealtimeLog]) {
        realtimeStore.append(contentsOf: logs)
        flushIfNeeded()
    }

    public func flush() {
        queue.async { [weak self] in
            self?.flushNetwork()
            self?.flushRealtime()
        }
    }

    private func flushIfNeeded() {
        queue.async { [weak self] in
            self?.flushNetwork()
            self?.flushRealtime()
        }
    }

    private func flushNetwork() {
        let logs = networkStore.drain(max: batchSize)
        guard !logs.isEmpty else { return }

        let url = baseURL.appendingPathComponent("v1/logs")
        post(logs, to: url, attempt: 1) { [weak self] success in
            guard let self else { return }
            if !success {
                self.networkStore.append(contentsOf: logs)
            }
        }
    }

    private func flushRealtime() {
        let logs = realtimeStore.drain(max: batchSize)
        guard !logs.isEmpty else { return }

        let url = baseURL.appendingPathComponent("v1/realtime-logs")
        post(logs, to: url, attempt: 1) { [weak self] success in
            guard let self else { return }
            if !success {
                self.realtimeStore.append(contentsOf: logs)
            }
        }
    }

    private func post<T: Encodable>(
        _ logs: [T],
        to url: URL,
        attempt: Int,
        completion: @escaping @Sendable (Bool) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")

        do {
            request.httpBody = try JSONEncoder().encode(logs)
        } catch {
            print("❌ Logora encoding failed:", error)
            completion(false)
            return
        }

        session.dataTask(with: request) { [weak self] _, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            let success = error == nil && (200...299).contains(statusCode ?? 0)

            if success {
                print("📡 Logora batch sent:", statusCode ?? 0)
                completion(true)
                return
            }

            guard let self else {
                completion(false)
                return
            }

            if attempt < self.maxRetries {
                let delay = pow(2.0, Double(attempt)) // 2s, 4s, 8s

                self.queue.asyncAfter(deadline: .now() + delay) {
                    self.post(logs, to: url, attempt: attempt + 1, completion: completion)
                }
            } else {
                print("❌ Logora batch failed after retries:", error as Any, statusCode as Any)
                completion(false)
            }
        }.resume()
    }

    private func startTimer() {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + flushInterval, repeating: flushInterval)

        timer.setEventHandler { [weak self] in
            self?.flushNetwork()
            self?.flushRealtime()
        }

        timer.resume()
        self.timer = timer
    }

    private func observeAppLifecycle() {
        #if canImport(UIKit)
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.flush()
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.flush()
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.flush()
        }
        #endif
    }

    private static func normalizedBaseURL(from url: URL) -> URL {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.path = ""
        components?.query = nil
        components?.fragment = nil
        return components?.url ?? url
    }
}
