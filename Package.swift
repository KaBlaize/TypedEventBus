// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TypedEventBus",
    platforms: [SupportedPlatform.iOS(SupportedPlatform.IOSVersion.v13)],
    products: [
        .library(
            name: "TypedEventBus",
            targets: ["TypedEventBus"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TypedEventBus",
            dependencies: []),
        .testTarget(
            name: "TypedEventBusTests",
            dependencies: ["TypedEventBus"]),
    ]
)
