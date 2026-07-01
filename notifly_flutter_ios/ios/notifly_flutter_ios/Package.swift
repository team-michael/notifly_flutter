// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "notifly_flutter_ios",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "notifly-flutter-ios",
            targets: ["notifly_flutter_ios"]
        )
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(
            url: "https://github.com/team-michael/notifly-ios-sdk.git",
            exact: "2.6.0"
        )
    ],
    targets: [
        .target(
            name: "notifly_flutter_ios",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "notifly_sdk", package: "notifly-ios-sdk")
            ]
        )
    ]
)
