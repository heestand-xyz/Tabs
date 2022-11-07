// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Tabs",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
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
