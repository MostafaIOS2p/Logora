// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Logora",
    platforms: [
        .iOS(.v13)   // 🔥 THIS FIXES IT
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Logora",
            targets: ["Logora"]),
    ],
    dependencies: [
      .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Logora",
            dependencies: [.product(name: "Alamofire", package: "Alamofire")]
         ),
        .testTarget(
            name: "LogoraTests",
            dependencies: ["Logora"]
        ),
    ]
)
