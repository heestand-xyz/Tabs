// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Tabs",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "Tabs",
            targets: ["Tabs"]),
    ],
    dependencies: [
        .package(url: "https://github.com/heestand-xyz/MultiViews", from: "3.1.0"),
    ],
    targets: [
        .target(
            name: "Tabs",
            dependencies: [
                "MultiViews",
            ]),
    ]
)
