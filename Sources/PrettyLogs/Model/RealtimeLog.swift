//
//  RealtimeLog.swift
//  PrettyLogs
//
//  Created by Mostafa Muhammad on 28/01/2026.
//


import Foundation

public struct RealtimeLog: Codable, Sendable {

    public enum Transport: String, Codable, Sendable {
        case socketIO
        case signalR
        case webSocket
        case custom
    }

    public enum Direction: String, Codable, Sendable {
        case incoming
        case outgoing
        case `internal`
    }

    public let id: UUID
    public let timestamp: String
    public let transport: Transport
    public let direction: Direction
    public let event: String
    public let payload: String?
    public let error: String?

    // metadata
    public let appId: String?
    public let environment: String?
    public let device: String?
    public let build: String?

    public init(
        id: UUID,
        timestamp: String,
        transport: Transport,
        direction: Direction,
        event: String,
        payload: String?,
        error: String?,
        appId: String?,
        environment: String?,
        device: String?,
        build: String?
    ) {
        self.id = id
        self.timestamp = timestamp
        self.transport = transport
        self.direction = direction
        self.event = event
        self.payload = payload
        self.error = error
        self.appId = appId
        self.environment = environment
        self.device = device
        self.build = build
    }
}
