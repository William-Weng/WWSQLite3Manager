// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWSQLite3Manager",
    platforms: [
        .iOS(.v14)
    ],
    products: [.library(name: "WWSQLite3Manager", targets: ["WWSQLite3Manager"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "WWSQLite3Manager", resources: [.copy("Privacy")]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
