import Foundation

public final class HTTPLogSink: LogSink {

    private let baseURL: URL
    private let apiKey: String
    private let session: URLSession

    public init(baseURL: URL, apiKey: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey

        let config = URLSessionConfiguration.default
        config.protocolClasses = [] // ✅ prevent URLProtocol recursion
        self.session = URLSession(configuration: config)
    }

    public func handle(_ log: NetworkLog) {
        sendNetwork([log])
    }

    public func handleRealtime(_ logs: [RealtimeLog]) {
        sendRealtime(logs)
    }

    private func sendNetwork(_ logs: [NetworkLog]) {
        let url = baseURL.appendingPathComponent("v1/logs")
        post(logs, to: url)
    }

    private func sendRealtime(_ logs: [RealtimeLog]) {
        let url = baseURL.appendingPathComponent("v1/realtime-logs")
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
            print("❌ Logora encoding failed:", error)
            return
        }

        session.dataTask(with: request) { _, response, error in
            if let error {
                print("❌ Logora transport error:", error)
            }

            if let http = response as? HTTPURLResponse {
                print("📡 Logora status:", http.statusCode)
            }
        }.resume()
    }
}
