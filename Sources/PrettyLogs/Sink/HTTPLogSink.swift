//
//  HTTPLogSink.swift
//  PrettyLogs
//
//  Created by Mostafa Muhammad on 22/01/2026.
//

        

import Foundation

public final class HTTPLogSink: LogSink {

    private let endpoint: URL
    private let apiKey: String
    private let session: URLSession

    public init(endpoint: URL, apiKey: String) {
        self.endpoint = endpoint
        self.apiKey = apiKey

        let config = URLSessionConfiguration.default
        config.protocolClasses = [] // 🔑 bypass URLProtocol completely
        self.session = URLSession(configuration: config)
    }
    public func handle(_ log: NetworkLog) {
        sendNetwork([log])
    }
    public func handleRealtime(_ logs: [RealtimeLog]) {
        sendRealtime(logs)
    }
    private func sendNetwork(_ logs: [NetworkLog]) {
        guard let url = URL(string: "/v1/logs", relativeTo: endpoint) else { return }
        post(logs, to: url)
    }
    private func sendRealtime(_ logs: [RealtimeLog]) {
        guard let url = URL(string: "/v1/realtime-logs", relativeTo: endpoint) else { return }
        post(logs, to: url)
    }

    private func post<T: Encodable>(_ logs: [T], to url: URL) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")

            do {
                request.httpBody = try JSONEncoder().encode(logs)
            } catch {
                print("❌ PrettyLogs encoding failed:", error)
                return
            }

        session.dataTask(with: request) { data, response, error in
            print("📡 HTTPLogSink response:", response as Any, error as Any)
        }.resume()
    }
}
