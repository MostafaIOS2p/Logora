//
//  NetworkLog.swift
//  PrettyLogs
//
//  Created by Mostafa Muhammad on 22/01/2026.
//


import Foundation

public struct NetworkLog: Codable {
    public let id: String
    public let timestamp: String     // ISO8601 string
    public let durationMs: Int

    // Request
    public let method: String
    public let url: String
    public let requestHeaders: [String: String]?
    public let requestBody: String?

    // Response
    public let statusCode: Int?
    public let responseHeaders: [String: String]?
    public let responseBody: String?

    // Error
    public let error: String?
    
    // Meta Data
    public let appId: String?
    public let environment: String?
    public let device: String?
    public let build: String?

    
}
