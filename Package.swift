// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Tabs",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "Tabs",
            targets: ["Tabs"]),
    ],
    targets: [
        .target(
            name: "Tabs",
            dependencies: []),
    ]
)
