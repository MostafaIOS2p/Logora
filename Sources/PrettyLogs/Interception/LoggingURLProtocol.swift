//
//  LoggingURLProtocol.swift
//  PrettyLogs
//
//  Created by Mostafa Muhammad on 22/01/2026.
//


import Foundation

final class LoggingURLProtocol: URLProtocol, @unchecked Sendable {
    
    private static let handledKey = "PrettyLogsHandledKey"

    private var tracker: NetworkLogTracker?
    private var dataTask: URLSessionDataTask?   // ✅ RENAMED

    override class func canInit(with request: URLRequest) -> Bool {
        print("🛰️ URLProtocol intercepted:", request.url?.absoluteString ?? "nil")

        let config = LoggerState.shared.config
        guard config.shouldLog(request: request) else { return false }

        if URLProtocol.property(forKey: handledKey, in: request) != nil {
            return false
        }
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let mutableRequest = (self.request as NSURLRequest).mutableCopy() as! NSMutableURLRequest

        URLProtocol.setProperty(
            true,
            forKey: Self.handledKey,
            in: mutableRequest
        )

        // Inject correlation id
        let correlationId = UUID().uuidString
        mutableRequest.setValue(correlationId, forHTTPHeaderField: "X-Correlation-ID")

        let newRequest = mutableRequest as URLRequest
        let tracker = NetworkLogTracker(request: newRequest, id: correlationId)
        self.tracker = tracker

        let cfg = URLSessionConfiguration.default
        cfg.protocolClasses = [] // prevent recursion
        let session = URLSession(configuration: cfg)

        dataTask = session.dataTask(with: newRequest) { [weak self] data, response, error in
            guard let self else { return }
            guard let tracker = self.tracker else { return }

            tracker.response = response as? HTTPURLResponse
            tracker.responseData = data
            tracker.error = error

            if let response = response {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = data {
                self.client?.urlProtocol(self, didLoad: data)
            }
            if let error = error {
                self.client?.urlProtocol(self, didFailWithError: error)
            } else {
                self.client?.urlProtocolDidFinishLoading(self)
            }

            let config = LoggerState.shared.config
            let log = NetworkLogBuilder.build(from: tracker, config: config)
            CompanyLogger.handle(log)
        }

        dataTask?.resume()
    }

    override func stopLoading() {
        dataTask?.cancel()
        dataTask = nil
    }
}
