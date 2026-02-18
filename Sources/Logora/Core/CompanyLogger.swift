//
//  CompanyLogger.swift
//  Logora
//
//  Created by Mostafa Muhammad on 15/02/2026.
//


import Foundation

public enum CompanyLogger {

    public static func handle(_ log: NetworkLog) {
        Task {
            await InternalLoggerContainer.shared.logHttp(log)
        }
    }
}
