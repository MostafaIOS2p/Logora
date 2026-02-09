//
//  LoggerMetadata.swift
//  PrettyLogs
//
//  Created by Mostafa Muhammad on 25/01/2026.
//


import Foundation

public struct LoggerMetadata: Sendable {
    public let appId: String
    public let environment: String
    public let device: String
    public let build: String

    public init(
        appId: String,
        environment: String,
        device: String,
        build: String
    ) {
        self.appId = appId
        self.environment = environment
        self.device = device
        self.build = build
    }
}