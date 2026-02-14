// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "intercom_flutter",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "intercom-flutter", targets: ["intercom_flutter"])
    ],
    dependencies: [
        .package(url: "https://github.com/intercom/intercom-ios-sp.git", exact: "19.5.1")
    ],
    targets: [
        .target(
            name: "intercom_flutter",
            dependencies: [
                .product(name: "Intercom", package: "intercom-ios-sp")
            ],
            resources: [],
            cSettings: [
                .headerSearchPath("include/intercom_flutter")
            ]
        )
    ]
)
