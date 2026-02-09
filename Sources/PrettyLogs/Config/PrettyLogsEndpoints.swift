//
//  PrettyLogsEndpoints.swift
//  PrettyLogs
//
//  Created by Mostafa Muhammad on 04/02/2026.
//

import Foundation

enum PrettyLogsEndpoints {
    static let httpLink = URL(string: "http://prettylogs-backend-production.up.railway.app/v1/logs")!
    static let realtime  = URL(string: "http://prettylogs-backend-production.up.railway.app/v1/realtime-logs")!
}
