

#if canImport(Alamofire)
import Foundation
import Alamofire

public final class CompanyAlamofireEventMonitor: EventMonitor, @unchecked Sendable {

    public let queue = DispatchQueue(label: "PrettyLogs.AlamofireEventMonitor")

    private let lock = NSLock()
    private var trackers: [UUID: NetworkLogTracker] = [:]

    public init() {}

    public func requestDidResume(_ request: Request) {
        let config = LoggerState.shared.config
        guard config.mode == .enabled else { return }
        guard let urlRequest = request.request else { return }

        guard config.shouldLog(request: urlRequest) else { return }

        let id = urlRequest.value(forHTTPHeaderField: "X-Correlation-ID")
            ?? UUID().uuidString

        let tracker = NetworkLogTracker(request: urlRequest, id: id)

        lock.lock()
        trackers[request.id] = tracker
        lock.unlock()
    }

    public func request(
        _ request: DataRequest,
        didParseResponse response: DataResponse<Data?, AFError>
    ) {
        lock.lock()
        let tracker = trackers.removeValue(forKey: request.id)
        lock.unlock()

        guard let tracker else { return }

        tracker.response = response.response
        tracker.responseData = response.data ?? response.value ?? nil
        tracker.error = response.error

        let config = LoggerState.shared.config
        let log = NetworkLogBuilder.build(from: tracker, config: config)
        CompanyLogger.handle(log)
    }
}
#endif
