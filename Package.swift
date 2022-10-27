// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Console",
    platforms: [
        .iOS("16.0"),
        .macOS("13.0"),
        .macCatalyst("16.0"),
    ],
    products: [
        .library(
            name: "Console",
            targets: ["Console"]),
    ],
    dependencies: [
        .package(url: "https://github.com/schwa/Everything", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Console",
            dependencies: ["Everything"]),
        .testTarget(
            name: "ConsoleTests",
            dependencies: ["Console"]),
    ]
)
