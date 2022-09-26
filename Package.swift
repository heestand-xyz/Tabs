// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Tabs",
    platforms: [
        .iOS(.v14),
        .tvOS(.v14),
        .macOS(.v11),
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
