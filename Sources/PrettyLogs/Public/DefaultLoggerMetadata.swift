//
//  DefaultLoggerMetadata.swift
//  PrettyLogs
//
//  Created by Mostafa Muhammad on 25/01/2026.
//


import UIKit

public enum DefaultLoggerMetadata {

    @MainActor
    public static func make(environment: String) -> LoggerMetadata {
        let bundle = Bundle.main

        let appId = bundle.bundleIdentifier ?? "unknown"

        let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        let build = bundle.infoDictionary?["CFBundleVersion"] as? String ?? "0"

        let device =
        "\(UIDevice.current.model) (\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))"

        return LoggerMetadata(
            appId: appId,
            environment: environment,
            device: device,
            build: "\(version) (\(build))"
        )
    }
}
