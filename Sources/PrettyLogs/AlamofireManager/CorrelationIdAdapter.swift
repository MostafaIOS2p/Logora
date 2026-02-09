//
//  CorrelationIdAdapter.swift
//  PrettyLogs
//
//  Created by Mostafa Muhammad on 22/01/2026.
//


#if canImport(Alamofire)
import Foundation
import Alamofire

public final class CorrelationIdAdapter: RequestAdapter {

    public init() {}

    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var req = urlRequest
        if req.value(forHTTPHeaderField: "X-Correlation-ID") == nil {
            req.setValue(UUID().uuidString, forHTTPHeaderField: "X-Correlation-ID")
        }
        completion(.success(req))
    }
}
#endif