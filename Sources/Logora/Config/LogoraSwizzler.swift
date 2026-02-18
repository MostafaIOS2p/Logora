//
//  LogoraSwizzler.swift
//  Logora
//
//  Created by Mostafa Muhammad on 18/02/2026.
//


import Foundation
import ObjectiveC.runtime

actor LogoraSwizzler {

    static let shared = LogoraSwizzler()

    private var didSwizzle = false

    func enableURLProtocolInjection() {
        guard !didSwizzle else { return }
        didSwizzle = true

        swizzle(
            cls: URLSessionConfiguration.self,
            original: NSSelectorFromString("defaultSessionConfiguration"),
            swizzled: #selector(URLSessionConfiguration.prettylogs_defaultSessionConfiguration)
        )

        swizzle(
            cls: URLSessionConfiguration.self,
            original: NSSelectorFromString("ephemeralSessionConfiguration"),
            swizzled: #selector(URLSessionConfiguration.prettylogs_ephemeralSessionConfiguration)
        )
    }

    private func swizzle(cls: AnyClass, original: Selector, swizzled: Selector) {
        guard
            let originalMethod = class_getClassMethod(cls, original),
            let swizzledMethod = class_getClassMethod(cls, swizzled)
        else {
            return
        }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

private extension URLSessionConfiguration {

    static func prettylogs_injectIfNeeded(_ config: URLSessionConfiguration) {
        var classes = config.protocolClasses ?? []

        // Avoid duplicates
        if classes.contains(where: { $0 == LoggingURLProtocol.self }) { return }

        // Put our protocol FIRST so it gets a chance to intercept
        classes.insert(LoggingURLProtocol.self, at: 0)
        config.protocolClasses = classes
    }

    // After swizzling:
    // - calling prettylogs_defaultSessionConfiguration() actually calls ORIGINAL defaultSessionConfiguration()
    @objc class func prettylogs_defaultSessionConfiguration() -> URLSessionConfiguration {
        let config = self.prettylogs_defaultSessionConfiguration()
        prettylogs_injectIfNeeded(config)
        return config
    }

    @objc class func prettylogs_ephemeralSessionConfiguration() -> URLSessionConfiguration {
        let config = self.prettylogs_ephemeralSessionConfiguration()
        prettylogs_injectIfNeeded(config)
        return config
    }
}
